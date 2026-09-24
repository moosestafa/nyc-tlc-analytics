import os
import json

import pyarrow as pa
import pyarrow.compute as pc
import pyarrow.parquet as pq

from google.cloud import bigquery
from google.oauth2 import service_account


def get_bq_client():
    key_json = json.loads(os.environ["GCP_SA_KEY"])

    credentials = service_account.Credentials.from_service_account_info(
        key_json
    )

    return bigquery.Client(
        credentials=credentials,
        project=os.environ["GCP_PROJECT_ID"]
    )


def get_target_type(bq_type):

    if bq_type in ("INTEGER", "INT64"):
        return pa.int64()

    if bq_type in ("FLOAT", "FLOAT64"):
        return pa.float64()

    return None


def normalize_schema(filepath, trip_type):

    bq_client = get_bq_client()

    table_id = (
        f"{os.environ['GCP_PROJECT_ID']}"
        f".raw.{trip_type}_trips"
    )

    bq_table = bq_client.get_table(table_id)

    target_schema = {
        field.name.lower(): field
        for field in bq_table.schema
    }

    parquet_file = pq.ParquetFile(filepath)

    temp_path = filepath + ".normalized.parquet"

    writer = None

    try:

        for batch in parquet_file.iter_batches(
            batch_size=250_000
        ):

            table = pa.Table.from_batches([batch])

            source_columns = {
                name.lower(): name
                for name in table.column_names
            }

            for lower_name, bq_field in target_schema.items():

                if lower_name not in source_columns:
                    continue

                column_name = source_columns[lower_name]

                target_type = get_target_type(
                    bq_field.field_type
                )

                # We're only normalizing numeric schema drift.
                if target_type is None:
                    continue

                column = table[column_name]

                needs_cast = False

                if (
                    pa.types.is_integer(target_type)
                    and not pa.types.is_integer(column.type)
                ):
                    needs_cast = True

                elif (
                    pa.types.is_floating(target_type)
                    and not pa.types.is_floating(column.type)
                ):
                    needs_cast = True

                if not needs_cast:
                    continue

                print(
                    f"Normalizing {trip_type}.{column_name}: "
                    f"{column.type} -> {target_type}"
                )

                # Nullable integer columns often arrive as FLOAT
                # because NULL/NaN values are present.
                if pa.types.is_floating(column.type):
                    column = pc.if_else(
                        pc.is_nan(column),
                        pa.scalar(None, type=column.type),
                        column
                    )

                column = pc.cast(
                    column,
                    target_type,
                    safe=False
                )

                column_index = table.schema.get_field_index(
                    column_name
                )

                table = table.set_column(
                    column_index,
                    column_name,
                    column
                )

            if writer is None:
                writer = pq.ParquetWriter(
                    temp_path,
                    table.schema
                )

            writer.write_table(table)

        if writer is not None:
            writer.close()

        os.replace(
            temp_path,
            filepath
        )

        print(
            f"Schema normalization complete: "
            f"{trip_type}"
        )

    except Exception:

        if writer is not None:
            writer.close()

        if os.path.exists(temp_path):
            os.remove(temp_path)

        raise
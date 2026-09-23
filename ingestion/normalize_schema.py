import os

import pyarrow as pa
import pyarrow.compute as pc
import pyarrow.parquet as pq


SCHEMA_FIXES = {
    "yellow": {
        "passenger_count": pa.int64(),
        "RatecodeID": pa.int64(),
    },
    "green": {
        "RatecodeID": pa.int64(),
    },
    "fhv": {
        "SR_Flag": pa.int64(),
    },
}


def normalize_schema(filepath, trip_type):

    fixes = SCHEMA_FIXES.get(trip_type)

    # FHVHV currently needs no fix
    if not fixes:
        return

    parquet_file = pq.ParquetFile(filepath)

    temp_path = filepath + ".normalized.parquet"

    writer = None

    try:
        for batch in parquet_file.iter_batches(batch_size=250_000):

            table = pa.Table.from_batches([batch])

            for column_name, target_type in fixes.items():

                if column_name not in table.column_names:
                    continue

                column_index = table.schema.get_field_index(column_name)
                column = table[column_name]

                # Convert floating NaN values to NULL before
                # casting FLOAT -> INTEGER
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

        os.replace(temp_path, filepath)

        print(f"Normalized schema for {trip_type}: {filepath}")

    except Exception:

        if writer is not None:
            writer.close()

        if os.path.exists(temp_path):
            os.remove(temp_path)

        raise
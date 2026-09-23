import os
import json

from google.cloud import bigquery
from google.oauth2 import service_account


def get_bq_client():
    key_json = json.loads(os.environ["GCP_SA_KEY"])
    credentials = service_account.Credentials.from_service_account_info(key_json)

    return bigquery.Client(
        credentials=credentials,
        project=os.environ["GCP_PROJECT_ID"]
    )


def is_loaded(trip_type, year, month,source_version):
    client = get_bq_client()

    query = f"""
        SELECT 1
        FROM `{os.environ["GCP_PROJECT_ID"]}.ops.ingestion_log`
        WHERE trip_type = @trip_type
          AND source_year = @source_year
          AND source_month = @source_month
          AND status = 'loaded'
          AND source_version = @source_version
        LIMIT 1
    """

    job_config = bigquery.QueryJobConfig(
        query_parameters=[
            bigquery.ScalarQueryParameter("trip_type", "STRING", trip_type),
            bigquery.ScalarQueryParameter("source_year", "INT64", year),
            bigquery.ScalarQueryParameter("source_month", "INT64", month),
            bigquery.ScalarQueryParameter("source_version","STRING",source_version)
        ]
    )

    rows = list(client.query(query, job_config=job_config).result())

    return len(rows) > 0


def record_status(
    trip_type,
    year,
    month,
    status,
    source_version=None,
    gcs_uri=None,
    attempt=None,
    bigquery_job_id=None,
    error_message=None
):
    client = get_bq_client()

    table_id = f"{os.environ['GCP_PROJECT_ID']}.ops.ingestion_log"

    row = {
        "trip_type": trip_type,
        "source_year": year,
        "source_month": month,
        "source_version": source_version,
        "gcs_uri": gcs_uri,
        "status": status,
        "attempt": attempt,
        "bigquery_job_id": bigquery_job_id,
        "started_at": None,
        "finished_at": None,
        "error_message": error_message,
    }

    errors = client.insert_rows_json(table_id, [row])

    if errors:
        raise RuntimeError(f"Failed to write ingestion status: {errors}")
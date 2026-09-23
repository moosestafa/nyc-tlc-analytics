import os
import json

from google.oauth2 import service_account
from google.api_core import exceptions
from google.cloud import bigquery


BUCKET_NAME = "nyc-tlc-raw-500621"
BQ_LOCATION = "US"


def get_bq_client():
    key_json = json.loads(os.environ["GCP_SA_KEY"])

    credentials = service_account.Credentials.from_service_account_info(
        key_json
    )

    return bigquery.Client(
        credentials=credentials,
        project=os.environ["GCP_PROJECT_ID"]
    )


def create_datasets():
    try:
        bq_client = get_bq_client()

        for dataset_name in ["raw", "staging", "marts", "ops"]:
            dataset = bigquery.Dataset(
                f"{os.environ['GCP_PROJECT_ID']}.{dataset_name}"
            )

            dataset.location = BQ_LOCATION

            bq_client.create_dataset(
                dataset,
                timeout=30,
                exists_ok=True
            )

    except exceptions.NotFound as e:
        print(f"Table, dataset, or project not found: {e}")
        raise

    except exceptions.BadRequest as e:
        print(f"SQL syntax or bad request error: {e}")
        raise

    except exceptions.Forbidden as e:
        print(f"Permission denied / IAM error: {e}")
        raise

    except exceptions.GoogleAPICallError as e:
        print(f"Generic BigQuery API error occurred: {e}")
        raise


def config_data():
    return bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.PARQUET,
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        autodetect=True
    )


def get_existing_job(bq_client, job_id):
    try:
        return bq_client.get_job(
            job_id,
            location=BQ_LOCATION
        )

    except exceptions.NotFound:
        return None


def load_table(trip_type, year, month,source_version):
    try:
        bq_client = get_bq_client()

        source_uri = (
            f"gs://{BUCKET_NAME}/"
            f"{trip_type}/{year}/{month:02d}/"
            f"{trip_type}-{year}-{month:02d}.parquet"
        )

        destination_table = (
            f"{os.environ['GCP_PROJECT_ID']}.raw."
            f"{trip_type}_trips"
        )

        load_config = config_data()

        attempt = 1

        while True:
            job_id = (
                f"load_{trip_type}_{year}_{month:02d}"
                f"_v{source_version}"
                f"_attempt_{attempt}"
            )

            existing_job = get_existing_job(
                bq_client,
                job_id
            )

            # This attempt already exists
            if existing_job is not None:

                # If it is still running, wait for it.
                if existing_job.state != "DONE":
                    existing_job.result()

                # Existing attempt succeeded.
                if existing_job.error_result is None:
                    print(
                        f"BigQuery load already succeeded "
                        f"with job {job_id}"
                    )

                    return job_id, attempt

                # Existing attempt failed.
                # Move on to the next attempt number.
                print(
                    f"Previous BigQuery load attempt "
                    f"{attempt} failed. Trying again."
                )

                attempt += 1
                continue

            # No job exists for this attempt yet.
            try:
                load_job = bq_client.load_table_from_uri(
                    source_uri,
                    destination_table,
                    job_config=load_config,
                    job_id=job_id
                )

            # Another process may have created the same
            # job between our check and our submission.
            except exceptions.Conflict:
                continue

            # Wait for the load to complete.
            # If BigQuery fails, this raises an exception.
            load_job.result()

            print(
                f"BigQuery load succeeded "
                f"with job {job_id}"
            )

            return job_id, attempt

    except exceptions.NotFound as e:
        print(f"Table, dataset, or project not found: {e}")
        raise

    except exceptions.BadRequest as e:
        print(f"SQL syntax or bad request error: {e}")
        raise

    except exceptions.Forbidden as e:
        print(f"Permission denied / IAM error: {e}")
        raise

    except exceptions.GoogleAPICallError as e:
        print(f"Generic BigQuery API error occurred: {e}")
        raise
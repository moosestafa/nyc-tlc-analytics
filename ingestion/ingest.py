import download
import upload_gcs
import dedup_check
import load_bq
import ingestion_status
import normalize_schema


def ingest(trip_type, year, month):

    source_version = None

    try:
        if not dedup_check.dedup_check(trip_type, year, month):

            filepath = (
                f"../data/"
                f"{trip_type}-{year}-{month:02d}.parquet"
            )

            # Download source Parquet file
            download.download(
                trip_type,
                year,
                month
            )

            # Normalize known TLC schema drift before upload
            normalize_schema.normalize_schema(
                filepath,
                trip_type
            )

            # Upload normalized file to GCS
            upload_gcs.upload_gcs(
                filepath,
                "nyc-tlc-raw-500621",
                f"{trip_type}/{year}/{month:02d}/"
                f"{trip_type}-{year}-{month:02d}.parquet"
            )

        else:
            print("File already exists in GCS")

        # Get the version of the file currently in GCS
        source_version = dedup_check.get_source_version(
            trip_type,
            year,
            month
        )

        # Check whether this exact version has already been loaded
        if ingestion_status.is_loaded(
            trip_type,
            year,
            month,
            source_version
        ):
            print("Already loaded")
            return True

        # Load GCS object into BigQuery
        bigquery_job_id, attempt = load_bq.load_table(
            trip_type,
            year,
            month,
            source_version
        )

        # Record successful load
        ingestion_status.record_status(
            trip_type,
            year,
            month,
            "loaded",
            source_version=source_version,
            attempt=attempt,
            bigquery_job_id=bigquery_job_id
        )

        return True

    except Exception as e:

        ingestion_status.record_status(
            trip_type,
            year,
            month,
            "failed",
            source_version=source_version,
            error_message=str(e)
        )

        print(
            f"Error occurred at "
            f"{trip_type}, {year}, {month}"
        )

        raise


if __name__ == "__main__":

    trip_types = [
        "yellow",
        "green",
        "fhv",
        "fhvhv"
    ]

    for year in [2019, 2024]:

        months = (
            range(2, 13)
            if year == 2019
            else range(1, 3)
        )

        for month in months:

            for trip_type in trip_types:

                print(
                    f"\nStarting ingestion: "
                    f"{trip_type} {year}-{month:02d}"
                )

                try:
                    ingest(
                        trip_type,
                        year,
                        month
                    )

                except Exception as e:
                    print(
                        f"FAILED: "
                        f"{trip_type} "
                        f"{year}-{month:02d}: "
                        f"{e}"
                    )
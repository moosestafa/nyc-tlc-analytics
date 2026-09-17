import download
import upload_gcs
import dedup_check
import load_bq
import ingestion_status


def ingest(trip_type, year, month):

    if ingestion_status.is_loaded(trip_type, year, month):
        print("Already loaded")
        return True

    try:
        if not dedup_check.dedup_check(trip_type, year, month):

            download.download(trip_type, year, month)

            upload_gcs.upload_gcs(
                f"../data/{trip_type}-{year}-{month:02d}.parquet",
                "nyc-tlc-raw-500621",
                f"{trip_type}/{year}/{month:02d}/{trip_type}-{year}-{month:02d}.parquet"
            )

        else:
            print("File already exists in GCS")

        load_bq.load_table(trip_type, year, month)

        ingestion_status.record_status(
            trip_type,
            year,
            month,
            "loaded"
        )
        return True
    except Exception as e:

        ingestion_status.record_status(
            trip_type,
            year,
            month,
            "failed",
            error_message=str(e)
        )

        print(f"Error occured at {trip_type}, {year}, {month}")
        raise
ingest("test", 2099, 1)
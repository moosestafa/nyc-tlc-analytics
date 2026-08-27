import os
import json
import download
import upload_gcs
import dedup_check
import load_bq



def ingest(trip_type, year, month):
    if dedup_check.dedup_check(trip_type, year, month):
        print("Already exists")
        return True
    else:
        try:
            download.download(trip_type, year, month)
            upload_gcs.upload_gcs(f"../data/{trip_type}-{year}-{month:02d}.parquet"
                       ,f"nyc-tlc-raw-500621"
                       ,f"{trip_type}/{year}/{month:02d}/{trip_type}-{year}-{month:02d}.parquet")
            load_bq.load_table(trip_type, year, month)
        except Exception as e:
            print(f"Error occured at {trip_type}, {year}, {month}")
            raise

ingest("fhvhv", 2019, 2)

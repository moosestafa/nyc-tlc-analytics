import os
import json
from google.cloud import storage
from google.oauth2 import service_account
from google.cloud import exceptions



def upload_gcs(filepath,bucket_name,destination_path):
    print("Here")
    # authentication for google cloud, takes env variable and passes it to google cloud
    try:
        key_json = json.loads(os.environ["GCP_SA_KEY"])
        credentials = service_account.Credentials.from_service_account_info(key_json)
        storage_client = storage.Client(credentials=credentials, project=os.environ["GCP_PROJECT_ID"])
    
    #bucket and blob creation
        bucket = storage_client.bucket(bucket_name)

        blob = bucket.blob(destination_path)

        blob.upload_from_filename(filepath)
        print(f"{filepath} uploaded to {destination_path} in {bucket_name}")
    #error handling for bucket not being found, insufficient IAM roles and general GC errors
    except exceptions.NotFound:
        print(f"Bucket {bucket_name} not found")
    except exceptions.Forbidden:
        print(f"Permission denied — check service account roles")
    except exceptions.GoogleCloudError as e:
        print(f"GCP error: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")
    

upload_gcs("data/yellow-2015-01.parquet","nyc-tlc-raw-500621","yellow/2015/01/yellow-2015-01.parquet")
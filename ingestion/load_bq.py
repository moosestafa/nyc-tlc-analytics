import os
import json
from google.cloud import storage
from google.oauth2 import service_account
from google.cloud import exceptions
from google.cloud import bigquery


def create_datasets():
    try:
        key_json = json.loads(os.environ["GCP_SA_KEY"])
        credentials = service_account.Credentials.from_service_account_info(key_json)
        bq_client = bigquery.Client(credentials=credentials, project=os.environ["GCP_PROJECT_ID"])

        dataset = bigquery.Dataset(f"{os.environ['GCP_PROJECT_ID']}.raw")
        dataset.location = "US"
        dataset = bq_client.create_dataset(dataset, timeout=30, exists_ok=True)  
        dataset = bigquery.Dataset(f"{os.environ['GCP_PROJECT_ID']}.staging")
        dataset.location = "US"
        dataset = bq_client.create_dataset(dataset, timeout=30, exists_ok=True)  #
        dataset = bigquery.Dataset(f"{os.environ['GCP_PROJECT_ID']}.marts")
        dataset.location = "US"
        dataset = bq_client.create_dataset(dataset, timeout=30, exists_ok=True)  #
    except exceptions.NotFound as e:
        print(f"Table, dataset, or project not found: {e.message}")
    
    except exceptions.BadRequest as e:
        print(f"SQL Syntax or bad request error: {e.message}")
    
    except exceptions.Forbidden as e:
        print(f"Permission denied / IAM error: {e.message}")
    
    except exceptions.GoogleAPICallError as e:
        print(f"Generic BigQuery API error occurred: {e.message}")

        

def config_data():


def load_table():

#!/bin/bash
mkdir -p ~/.dbt
echo "$GCP_SA_KEY" > ~/.dbt/gcp-key.json
echo "GCP key written to ~/.dbt/gcp-key.json"

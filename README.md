Docker image for downloading and CSV zip file from GCS and import it in elasticsearch.

##Requirements:
- Elasticsearch up and running. Host and port for running elasticsearch via pelias configuration.
- Service account for accessing the bucket where the CSV zip file exists.
- Needs following Environment variable:
  - GCP_SA_KEY = Path to service account key.
  - GCS_BASE_PATH = Path to directory containing the CSV zip file.
  - PELIAS_CONFIG = Path to pelias config to use.

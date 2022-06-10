#!/bin/bash

echo "Start executing the script"

gcloud auth activate-service-account --key-file "$GCP_SA_KEY"

basePath=$GCS_BASE_PATH
filePath=$(gsutil cat ${basePath}current)
currentPath=$basePath$filePath

zipFileNameLocal="tiamat_export_geocoder_latest.zip"

gsutil -m cp "$currentPath" "$zipFileNameLocal" 2>temp
if [ $? == 1 ]; then
  grep 'CommandException' temp
  if [ $? == 0 ]; then
    echo "Something went wrong while copying file from gcs"
  else
    echo "Current file copied"
  fi
fi
rm temp

current=./"$zipFileNameLocal"
if [ ! -e "$current" ]; then
  echo "no current file found, exit!"
  exit 1
else
  echo "extracting current csv data file"
  mkdir csv
  unzip "$zipFileNameLocal" -d csv <<<'y'
fi

echo "Dropping index..."
node "$WORKDIR"/node_modules/pelias-schema/scripts/drop_index.js <<<'y'

echo "Creating index..."
node "$WORKDIR"/node_modules/pelias-schema/scripts/create_index.js
if [ $? == 1 ]; then
  echo "Failed to create the index."
else
  echo "Importing csv data into elasticsearch..."
  cd "$WORKDIR"/node_modules/pelias-csv-importer || exit
  ./bin/start
  if [ $? == 1 ]; then
    echo "Failed to import csv file."
  else
    echo "CSV file imported into elasticsearch, Starting Pelias API"
    cd "$WORKDIR"/node_modules/pelais-api || exit
    ./bin/start
  fi
fi

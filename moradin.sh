#!/bin/bash

echo "Start executing the moradin script"

waiting="1"
until [[ $waiting -eq "0" ]]; do
  echo "Waiting for elasticsearch..."
  sleep 1
  curl -X GET "http://127.0.0.1:9200/_cluster/health?wait_for_status=green&timeout=50s&pretty"
  waiting=$?
done

echo "Elasticsearch up and running."

basePath=gs://"$BUCKET_NAME"/import
fileName=$(gsutil cat "${basePath}"current)
currentPath=$basePath$fileName

zipFileNameLocal=$fileName

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
    cd "$WORKDIR"/node_modules/pelias-api || exit
    ./bin/start
  fi
fi

echo "Finished with the moradin script."

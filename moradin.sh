#!/bin/bash

echo "Start executing the moradin script"

waiting="1"
until [[ $waiting -eq "0" ]]; do
  echo "Waiting for elasticsearch..."
  sleep 5
  curl -X GET "http://127.0.0.1:9200/_cluster/health?wait_for_status=yellow&timeout=50s&pretty"
  waiting=$?
done

echo "Elasticsearch up and running."

importPath=gs://"$BUCKET_NAME"/import
echo "Reading files from $importPath"
fileName=$(gsutil ls "$importPath" | sort -k 2)

zipFileNameLocal="haya_latest.zip"

gsutil -m cp "$fileName" "$zipFileNameLocal" 2>temp
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
  echo "extracting $zipFileNameLocal"
  mkdir csv
  unzip "$zipFileNameLocal" -d csv <<<'y'
fi

echo "Splitting the unzipped file"
unzippedFilename=$(unzip -Z1 "$zipFileNameLocal")
echo "Unzipped file name: $unzippedFilename"
cd csv || exit
mkdir files
numberOfRecords=$(wc -l < "$unzippedFilename")
echo "Number of records $numberOfRecords"
cat "$unzippedFilename" | parallel --header : --pipe -N"$((numberOfRecords / 6))" 'cat >> ./files/file_{#}.csv'
if [ $? == 1 ]; then
  echo "Failed to split the unzipped file"
else
  echo "Creating index..."
  node "$WORKDIR"/node_modules/pelias-schema/scripts/create_index.js
  if [ $? == 1 ]; then
    echo "Failed to create the index."
  else
    echo "Importing csv data into elasticsearch..."
    cd "$WORKDIR"/node_modules/pelias-csv-importer || exit
    ./bin/parallel 6
    if [ $? == 1 ]; then
      echo "Failed to import csv file."
    else
      echo "CSV file imported into elasticsearch, Starting Pelias API"
      cd "$WORKDIR"/node_modules/pelias-api || exit
      ./bin/start
    fi
  fi
fi
echo "Finished with the moradin script."

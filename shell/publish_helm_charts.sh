#!/bin/bash

cd kubernetes/dist/packages/ || exit
while IFS= read -a line; do
    charts+=( "$line" )
done < <( ls )

for chart in "${charts[@]}"
do
  chart=$(echo "$chart" | xargs)
#  curl -n --upload-file $chart https://nexus.onap.org/content/sites/helm-charts/$BUILD_TYPE/$BUILD_ID/$chart
done
cd ../../../

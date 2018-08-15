#!/bin/bash

cd kubernetes/dist/packages/ || exit
while IFS= read -a line; do
    charts+=( "$line" )
done < <( ls )

for chart in "${charts[@]}";
do
  chart=$(echo "$chart" | xargs)
  case $BUILD_TYPE in
    'snapshot')
      curl -n --upload-file $chart https://nexus.onap.org/content/sites/oom-helm-$BUILD_TYPE/$chart
      curl -n --upload-file $chart https://nexus.onap.org/content/sites/oom-helm-$BUILD_TYPE/$GIT_COMMIT/$chart
      ;;
    'staging')
      curl -n --upload-file $chart https://nexus.onap.org/content/sites/oom-helm-$BUILD_TYPE/$chart
      curl -n --upload-file $chart https://nexus.onap.org/content/sites/oom-helm-$BUILD_TYPE/$GIT_COMMIT/$chart
      ;;
    'release')
      echo "Release automation not implemented yet."
      exit 1
        ;;
    *)
      echo "You must set BUILD_TYPE to one of (snapshot, staging, release)."
      exit 1
      ;;
  esac
done
cd ../../../

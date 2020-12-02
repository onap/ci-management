#!/bin/bash

set -e -o pipefail
cd kubernetes/dist/packages/ || exit
helm_charts=()
while IFS= read -a line; do
    helm_charts+=( "$line" )
done < <( ls )

for chart in "${helm_charts[@]}"; do
  chart=$(echo "$chart" | xargs)
  case "$BUILD_TYPE" in
    'snapshot')
      echo "-n --upload-file $chart https://nexus.onap.org/content/sites/oom-helm-$BUILD_TYPE/$GERRIT_BRANCH/$chart"
      curl -n --upload-file "$chart" "https://nexus.onap.org/content/sites/oom-helm-$BUILD_TYPE/$GERRIT_BRANCH/$chart"
      curl -n --upload-file "$chart" "https://nexus.onap.org/content/sites/oom-helm-$BUILD_TYPE//$GERRIT_BRANCH/$GIT_COMMIT/$chart"
      ;;
    'staging')
      curl -n --upload-file "$chart" "https://nexus.onap.org/content/sites/oom-helm-$BUILD_TYPE/$GERRIT_BRANCH/$chart"
      curl -n --upload-file "$chart" "https://nexus.onap.org/content/sites/oom-helm-$BUILD_TYPE/$GERRIT_BRANCH/$GIT_COMMIT/$chart"
      ;;
    'release')
      curl -n --upload-file "$chart" "https://nexus.onap.org/content/sites/oom-helm-$BUILD_TYPE/$chart"
        ;;
    *)
      echo "You must set BUILD_TYPE to one of (snapshot, staging, release)."
      exit 1
      ;;
  esac
done
cd ../../../

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
      curl -n --upload-file "$chart" "https://nexus3.onap.org/repository/onap-helm-testing/"
      ;;
    'staging')
      curl -n --upload-file "$chart" "https://nexus3.onap.org/repository/onap-helm-testing/"
      ;;
    'release')
      curl -n --upload-file "$chart" "https://nexus3.onap.org/repository/onap-helm-release/"
        ;;
    *)
      echo "You must set BUILD_TYPE to one of (snapshot, staging, release)."
      exit 1
      ;;
  esac
done
cd ../../../

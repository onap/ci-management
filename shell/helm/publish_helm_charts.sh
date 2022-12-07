#!/bin/bash

set -e -o pipefail
echo "*** starting chart publish process for $BUILD_TYPE"
cd kubernetes/dist/packages/ || exit
helm_charts=()
while IFS= read -a line; do
    helm_charts+=( "$line" )
done < <( ls )

for chart in "${helm_charts[@]}"; do
  chart=$(echo "$chart" | xargs)
  echo " ** processing chart $chart"
  case "$BUILD_TYPE" in
    'snapshot')
      echo "  * snapshot build, pushing to https://nexus3.onap.org/repository/onap-helm-testing/"
      curl -vn --upload-file "$chart" "https://nexus3.onap.org/repository/onap-helm-testing/"
      ;;
    'release')
      echo "  * release build, pushing to https://nexus3.onap.org/repository/onap-helm-release/"
      curl -vn --upload-file "$chart" "https://nexus3.onap.org/repository/onap-helm-release/"
        ;;
    *)
      echo "You must set BUILD_TYPE to one of (snapshot, release)."
      exit 1
      ;;
  esac
done
echo "*** chart publish process finished"
cd ../../../

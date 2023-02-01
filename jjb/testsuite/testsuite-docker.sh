#!/bin/bash
#
echo '============== CALLING SCRIPT TO CREATE DOCKER IMAGES ================='
cp $WORKSPACE/docker/* .
docker -D build --no-cache -t onap/testsuite .
export REPO="nexus3.onap.org:10003"

DATETIME_STAMP=$(date +%Y%m%dT%H%M%S)
STAGING_TAG=${base_version}-STAGING-${DATETIME_STAMP}Z

for tag in $tags $STAGING_TAG
do
  docker tag onap/testsuite:latest $REPO/onap/testsuite:$tag
  docker push $REPO/onap/testsuite:$tag
done

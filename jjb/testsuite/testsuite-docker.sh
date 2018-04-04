#!/bin/bash
#
echo '============== CALLING SCRIPT TO CREATE DOCKER IMAGES ================='
cp $WORKSPACE/docker/* .
docker -D build -t onap/testsuite .
export REPO="nexus3.onap.org:10003"
for tag in $tags
do
  docker tag onap/testsuite:latest $REPO/onap/testsuite:$tag
  docker push $REPO/onap/testsuite:$tag
done

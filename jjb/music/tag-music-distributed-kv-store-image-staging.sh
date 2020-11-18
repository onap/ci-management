#!/bin/bash

echo '=========== CALLING SCRIPT TO TAG DOCKER IMAGES AS STAGING ==========='
echo "=========== Unique docker tag: ${UNIQUE_DOCKER_TAG}"
CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./deployment/*.sh
cd ./deployment
./tag-docker-staging.sh

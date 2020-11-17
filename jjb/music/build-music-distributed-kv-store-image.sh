#!/bin/bash

echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='
echo "============== Unique docker tag: ${UNIQUE_DOCKER_TAG}"
CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./deployment/*.sh
cd ./deployment
./docker-build.sh

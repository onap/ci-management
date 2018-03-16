#!/bin/bash

echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='
CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./deployment/*.sh
cd ./deployment
./docker-build.sh

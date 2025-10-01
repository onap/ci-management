#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./*.*
cd ./valetapi
./build-dockers.sh

cd ../engine
./build-dockers.sh

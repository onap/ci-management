#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./ems/microservice-standalone/src/main/assembly/docker/*.*

./ems/microservice-standalone/src/main/assembly/docker/build_image.sh


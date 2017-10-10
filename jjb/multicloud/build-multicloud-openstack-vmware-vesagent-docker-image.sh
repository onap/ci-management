#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

echo '========================== Building docker for vesagent =========================='
chmod 755 ./vesagent/docker/*.*
./vesagent/docker/docker-build.sh

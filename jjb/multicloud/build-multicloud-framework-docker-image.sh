#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./multivimbroker/docker/*.*
chmod 755 ./artifactbroker/docker/*.*

./multivimbroker/docker/build_image.sh
./artifactbroker/docker/build_image.sh
#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./zte/sfc-driver/plugin-standalone/src/main/assembly/docker/*.*

./zte/sfc-driver/plugin-standalone/src/main/assembly/docker/build_image.sh


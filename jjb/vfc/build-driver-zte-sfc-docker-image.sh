#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./zte/sfc-driver/docker/*.*

./zte/sfc-driver/docker/build_image.sh


#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./newton/docker/*.*
chmod 755 ./ocata/docker/*.*
chmod 755 ./windriver/docker/*.*

./newton/docker/build_image.sh
./ocata/docker/build_image.sh
./windriver/docker/build_image.sh

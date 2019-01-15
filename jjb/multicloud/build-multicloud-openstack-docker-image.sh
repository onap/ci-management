#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./newton/docker/*.*
chmod 755 ./ocata/docker/*.*
chmod 755 ./windriver/docker/*.*
chmod 755 ./pike/docker/*.*
chmod 755 ./starlingx/docker/*.*

./newton/docker/build_image.sh
./ocata/docker/build_image.sh
./windriver/docker/build_image.sh
./pike/docker/build_image.sh
./starlingx/docker/build_image.sh

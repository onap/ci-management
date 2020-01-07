#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./windriver/docker/*.*
chmod 755 ./pike/docker/*.*
chmod 755 ./starlingx/docker/*.*
#chmod 755 ./lenovo/docker/*.*
chmod 755 ./fcaps/docker/*.*
chmod 755 ./hpa/docker/*.*

./windriver/docker/build_image.sh
./pike/docker/build_image.sh
./starlingx/docker/build_image.sh
#./lenovo/docker/build_image.sh
./fcaps/docker/build_image.sh
./hpa/docker/build_image.sh

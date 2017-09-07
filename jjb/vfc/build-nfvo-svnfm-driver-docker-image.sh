#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./zte/vmanager/docker/*.*
./zte/vmanager/docker/build_image.sh

chmod 755 ./VnfmadapterService/docker/*.*
./VnfmadapterService/docker/build_image.sh

#!/bin/bash

echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./gvnfmadapter/docker/*.*

./gvnfmadapter/docker/build_image.sh


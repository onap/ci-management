#!/bin/bash

echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./res/docker/*.*

./res/docker/build_image.sh


#!/bin/bash

echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./mgr/docker/*.*

./mgr/docker/build_image.sh


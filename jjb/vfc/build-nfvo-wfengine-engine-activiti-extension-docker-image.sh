#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./activiti-extension/src/main/docker/*.sh
./activiti-extension/src/main/docker/activiti-docker-build_image.sh


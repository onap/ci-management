#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./wfenginemgrservice/src/main/docker/*.sh
./wfenginemgrservice/src/main/docker/wfenginemgrservice-docker-build_image.sh


#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 *.*

./build4basedocker.sh
./build4docker.sh


#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

echo 'Building AAF/sshsm containers'
cd bin
chmod 755 build_images.sh
./build_images.sh

#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

echo 'Building AAF/sshsm base containers'
cd bin/base
chmod 755 build_base_images.sh
sh build_base_images.sh

#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./openstack/newton/docker/*.*
chmod 755 ./openstack/ocata/docker/*.*

./openstack/newton/docker/build_image.sh
./openstack/ocata/docker/build_image.sh

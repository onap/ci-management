#!/bin/bash

echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./gvnfmadapter/docker/*.*
./gvnfmadapter/docker/build_image.sh

# juju-vnfmadapter is removed 
# chmod 755 ./juju/juju-vnfmadapter/Juju-vnfmadapterService/docker/*.*
# ./juju/juju-vnfmadapter/Juju-vnfmadapterService/docker/build_image.sh


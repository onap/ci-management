#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./zte/vmanager/docker/*.*
./zte/vmanager/docker/build_image.sh

chmod 755 ./huawei/vnfmadapter/VnfmadapterService/docker/*.*
./huawei/vnfmadapter/VnfmadapterService/docker/build_image.sh

cd nokia/deployment
mvn package -Dexec.args="buildDocker pushImage"


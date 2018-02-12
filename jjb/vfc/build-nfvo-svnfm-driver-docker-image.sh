#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./zte/vmanager/docker/*.*
./zte/vmanager/docker/build_image.sh

chmod 755 ./huawei/vnfmadapter/VnfmadapterService/docker/*.*
./huawei/vnfmadapter/VnfmadapterService/docker/build_image.sh

chmod 755 ./nokia/vnfmdriver/vfcadaptorservice/docker/*.*
./nokia/vnfmdriver/vfcadaptorservice/docker/build_image.sh

cd nokiav2/deployment
mvn package -Dexec.args="buildDocker pushImage"


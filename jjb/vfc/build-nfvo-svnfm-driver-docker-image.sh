#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

echo '============== BUILDING ZTE IMAGE ================='
chmod 755 ./zte/vmanager/docker/*.*
./zte/vmanager/docker/build_image.sh

echo '============== BUILDING HUAWEI IMAGE ================='
chmod 755 ./huawei/vnfmadapter/VnfmadapterService/docker/*.*
./huawei/vnfmadapter/VnfmadapterService/docker/build_image.sh

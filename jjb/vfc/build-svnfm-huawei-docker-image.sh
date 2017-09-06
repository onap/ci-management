#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 ./huawei/vnfmadapter/VnfmadapterService/docker/*.*

./huawei/vnfmadapter/VnfmadapterService/docker/build_image.sh


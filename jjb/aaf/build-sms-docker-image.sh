#!/bin/bash
#
echo '============== CALLING SCRIPT TO BUILD DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR
mvn clean install
cd sms-service/bin/
chmod 755 *.sh
./build_image.sh
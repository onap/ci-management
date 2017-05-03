#!/bin/bash
#
echo '============== CALLING SCRIPT TO VERIFY DOCKER IMAGES ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 *.*

./docker_verify.sh

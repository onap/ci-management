#!/bin/bash
#
echo '========= CALLING SCRIPT TO BUILD ONECLICK CONFIG TAR FILE ========='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

cd kubernetes/config/docker/init

chmod 755 *.*

docker build .

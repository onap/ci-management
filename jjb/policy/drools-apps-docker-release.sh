#!/bin/bash
#
echo '============== CALLING SCRIPT TO RELEASE DROOLS APPLICATIONS DOCKER IMAGE ================='

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

chmod 755 controlloop/build/docker-cl

controlloop/build/docker-cl --release

#!/bin/bash
# Create a debian package and push to remote repo
#
#
# build the docker image. tag and then push to the remote repo
#

# !!! make sure the yaml file include docker-login as a builder before calling
# this script

IMAGE="dcae_dmaapbc"
TAG="1.0.0"
LFQI="${IMAGE}:${TAG}"
BUILD_PATH="${WORKSPACE}"

# build a docker image
docker build --rm -f ${WORKSPACE}/Dockerfile -t ${LFQI} ${BUILD_PATH}



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


#
# push the image
#
# io registry  DOCKER_REPOSITORIES="nexus3.openecomp.org:10001 \
# release registry                   nexus3.openecomp.org:10002 \
# snapshot registry                   nexus3.openecomp.org:10003"
DISTRIBUTION_STAGE=`cat ${WORKSPACE}/${PROJECT}-diststage`
if [ "$DISTRIBUTION_STAGE" == "SNAPSHOT" ]; then
    REPO="nexus3.openecomp.org:10003"
elif [ "$DISTRIBUTION_STAGE" == "RELEASE" ]; then
    REPO="nexus3.openecomp.org:10002"
elif [ "$DISTRIBUTION_STAGE" == "PUBLIC" ]; then
    REPO="nexus3.openecomp.org:10001"
else
    REPO=""
fi

if [ ! -z "$REPO" ]; then
    RFQI="${REPO}/${LFQI}"
    # tag
    docker tag ${LFQI} ${RFQI}

    # push to remote repo
    docker push ${RFQI}
fi




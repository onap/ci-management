#!/bin/bash

RELEASE_REPOSITORY="nexus3.openecomp.org:10002"
SNAPSHOT_REPOSITORY="nexus3.openecomp.org:10003"

if [ -z "$STAGING_IMAGE_NAME" ];
then
    echo "Error: no staging image name provided"
    exit 1
fi

if [ -z "$RELEASE_IMAGE_NAME" ];
then
    echo "Error: no release image name provided"
    exit 1
fi

docker pull "$SNAPSHOT_REPOSITORY/$STAGING_IMAGE_NAME"
docker tag "$STAGING_IMAGE_NAME" "$RELEASE_REPOSITORY/$RELEASE_IMAGE_NAME"
docker push "$RELEASE_REPOSITORY/$RELEASE_IMAGE_NAME"
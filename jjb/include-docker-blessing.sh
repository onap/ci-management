#!/bin/bash

if [ -z "$X" ];
then
    echo "Error: no X version provided"
    exit 1
fi

if [ -z "$Y" ];
then
    echo "Error: no Y version provided"
    exit 1
fi

if [ -z "$Z" ];
then
    echo "Error: no Z version provided"
    exit 1
fi

if [ -z "$PROJECT" ];
then
    echo "Error: no project provided"
    exit 1
fi

RELEASE_REPOSITORY="nexus3.onap.org:10002"
SNAPSHOT_REPOSITORY="nexus3.onap.org:10003"
STAGING_IMAGE="ecomp/$PROJECT:$X.$Y-STAGING-latest"
RELEASE_IMAGE="ecomp/$PROJECT:$X.$Y.$Z"

docker pull "$SNAPSHOT_REPOSITORY/$STAGING_IMAGE"
docker tag "$SNAPSHOT_REPOSITORY/$STAGING_IMAGE" "$RELEASE_REPOSITORY/$RELEASE_IMAGE"
docker push "$RELEASE_REPOSITORY/$RELEASE_IMAGE"

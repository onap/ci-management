#!/bin/bash

if [ -z "$VERSION" ];
then
    echo "Error: no version provided"
    exit 1
fi

if [ -z "$TIMESTAMP" ];
then
    echo "Error: no timestamp provided"
    exit 1
fi

if [ -z "$PROJECT" ];
then
    echo "Error: no project provided"
    exit 1
fi

RELEASE_REPOSITORY="nexus3.openecomp.org:10002"
SNAPSHOT_REPOSITORY="nexus3.openecomp.org:10003"
STAGING_IMAGE="openecomp/$PROJECT:$VERSION-STAGING-$TIMESTAMP"
RELEASE_IMAGE="openecomp/$PROJECT:$VERSION"

docker pull "$SNAPSHOT_REPOSITORY/$STAGING_IMAGE"
docker tag "$SNAPSHOT_REPOSITORY/$STAGING_IMAGE" "$RELEASE_REPOSITORY/$RELEASE_IMAGE"
docker push "$RELEASE_REPOSITORY/$RELEASE_IMAGE"
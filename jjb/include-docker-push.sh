#!/bin/bash

DOCKER_REPOSITORY="nexus3.onap.org:10003"
SEARCH="aai-service";
DATETIME_STAMP=$(date +%Y%m%dT%H%M%S);
VERSION_FILE="version.properties"

# Check for the version file
# If it exists, load the version from that file
# If not found, then use the current version as 1.1.0 for docker images
if [ -f "$VERSION_FILE" ]; then
    source $VERSION_FILE;
    VERSION=$release_version;
else
    VERSION=1.1.0;
fi

RELEASE_VERSION_REGEX="^[0-9]+\.[0-9]+\.[0-9]+$";

SNAPSHOT_TAG=${VERSION}-SNAPSHOT-${DATETIME_STAMP}Z;
STAGING_TAG=${VERSION}-STAGING-${DATETIME_STAMP}Z;


# Set REPO_PATH variable

if [ ! -z "$DOCKER_IMAGE_NAME" ]; then
    REPO_PATH=$DOCKER_REPOSITORY/${DOCKER_IMAGE_NAME};

    # tag image with nexus3 proxy prefix
    docker tag ${DOCKER_IMAGE_NAME} $REPO_PATH
elif [[ $PROJECT =~ $SEARCH ]] ; then
    REPO_PATH=$DOCKER_REPOSITORY/onap/ajsc-aai;
else
    # Cut the prefix aai/ in example aai/model-loader
    DOCKER_REPO_NAME=$(echo ${PROJECT} | cut -d"/" -f2-);

    REPO_PATH=$DOCKER_REPOSITORY/onap/${DOCKER_REPO_NAME};
fi


docker tag $REPO_PATH:latest $REPO_PATH:$STAGING_TAG;
docker tag $REPO_PATH:latest $REPO_PATH:$SNAPSHOT_TAG;

if [[ "$VERSION" =~ $RELEASE_VERSION_REGEX ]]; then
    STRIPPED_RELEASE=$(echo $VERSION | cut -d"." -f1,2);
    docker tag $REPO_PATH:latest $REPO_PATH:${STRIPPED_RELEASE}-STAGING-latest;
    docker push $REPO_PATH:${STRIPPED_RELEASE}-STAGING-latest;
else
    docker push $REPO_PATH:latest;
fi

docker push $REPO_PATH:$SNAPSHOT_TAG;
docker push $REPO_PATH:$STAGING_TAG;

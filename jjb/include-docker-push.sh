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


SNAPSHOT_TAG=${VERSION}-SNAPSHOT-${DATETIME_STAMP};
STAGING_TAG=${VERSION}-STAGING-${DATETIME_STAMP};

if [[ $PROJECT =~ "resources" ]] || [[ $PROJECT =~ "traversal" ]]; then
    exit;
fi;

if [[ $PROJECT =~ $SEARCH ]] ; then

    REPO_PATH=$DOCKER_REPOSITORY/openecomp/ajsc-aai;

    docker tag $REPO_PATH:latest $REPO_PATH:$STAGING_TAG;
    docker tag $REPO_PATH:latest $REPO_PATH:$SNAPSHOT_TAG;

    if [ "$VERSION" == "1.0.0" ]; then
        docker tag $REPO_PATH:latest $REPO_PATH:1.0-STAGING-latest;
        docker push $REPO_PATH:1.0-STAGING-latest;
    elif [ "$VERSION" == "1.1.0" ]; then
        docker tag $REPO_PATH:latest $REPO_PATH:1.1-STAGING-latest;
        docker push $REPO_PATH:1.1-STAGING-latest;
    else
        docker push $REPO_PATH:latest;
    fi

    docker push $REPO_PATH:$STAGING_TAG;
    docker push $REPO_PATH:$SNAPSHOT_TAG;
else
    # Cut the prefix aai/ in example aai/model-loader
    DOCKER_REPO_NAME=$(echo ${PROJECT} | cut -d"/" -f2-);

    REPO_PATH=$DOCKER_REPOSITORY/openecomp/${DOCKER_REPO_NAME};

    docker tag $REPO_PATH:latest $REPO_PATH:$STAGING_TAG;
    docker tag $REPO_PATH:latest $REPO_PATH:$SNAPSHOT_TAG;

    if [ "$VERSION" == "1.0.0" ]; then
        docker tag $REPO_PATH:latest $REPO_PATH:1.0-STAGING-latest;
        docker push $REPO_PATH:1.0-STAGING-latest;
    else
        docker push $REPO_PATH:latest;
    fi

    docker push $REPO_PATH:$SNAPSHOT_TAG;
    docker push $REPO_PATH:$STAGING_TAG;
fi

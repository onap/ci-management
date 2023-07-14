#!/bin/bash
# Ensure we fail the job if any steps fail
# Do not set -u as DOCKER_ARGS may be unbound
set -e -o pipefail#
set -x

FULL_DATE=`date +'%Y%m%dT%H%M%S'`

function get_image_version_maven() {
  echo `xmlstarlet sel -N "x=http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:version" pom.xml | cut -c1-5`
}
function get_image_version_gradle() {
  echo `cat build.gradle | grep -o 'version = [^,]*' | tr -d ' '| cut -d "=" -f 2`
}

if [ -f "pom.xml" ]; then
    IMAGE_VERSION=`get_image_version_maven`
    echo "Image version extracted from pom.xml"
elif [ -f "build.gradle" ]; then
    IMAGE_VERSION=`get_image_version_gradle`
    echo "Image version extracted from build.gradle"
else
    echo "Could not extract image version from build file"
fi

case "$BUILD_MODE" in
   "STAGING")
      DOCKER_TAG="$IMAGE_VERSION"-STAGING-"$FULL_DATE"Z
      DOCKER_LATEST_TAG="$IMAGE_VERSION"-STAGING-latest
      echo "Using tags $DOCKER_TAG and $DOCKER_LATEST_TAG"
      ;;
   "SNAPSHOT")
      DOCKER_TAG="$IMAGE_VERSION"-SNAPSHOT-"$FULL_DATE"Z
      DOCKER_LATEST_TAG="$IMAGE_VERSION"-SNAPSHOT-latest
      echo "Using tags $DOCKER_TAG and $DOCKER_LATEST_TAG"
      ;;
esac

# Switch to the directory where the Dockerfile is
cd "$DOCKER_ROOT"

# DOCKERREGISTRY is purposely not using an '_' so as to not conflict with the
# Jenkins global env var of the DOCKER_REGISTRY which the docker-login step uses
IMAGE_NAME="$DOCKERREGISTRY/$DOCKER_NAME:$DOCKER_TAG"
IMAGE_NAME_LATEST="$DOCKERREGISTRY/$DOCKER_NAME:$DOCKER_LATEST_TAG"

# Build the docker image

# Allow word splitting
# shellcheck disable=SC2086
docker build $DOCKER_ARGS . -t $IMAGE_NAME -t $IMAGE_NAME_LATEST | tee "$WORKSPACE/docker_build_log.txt"

# Write DOCKER_IMAGE information to a file so it can be injected into the
# environment for following steps
echo "DOCKER_IMAGE=$IMAGE_NAME" >> "$WORKSPACE/env_inject.txt"
echo "DOCKER_IMAGE_LATEST=$IMAGE_NAME_LATEST" >> "$WORKSPACE/env_inject.txt"



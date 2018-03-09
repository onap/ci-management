#!/bin/bash

# Script to download PyPI artifacts

PROJECT_NAME=$(grep name= setup.py | cut -d"'" -f2)
ARTIFACT_VERSION=$(grep __version__ ${PROJECT_NAME}/_version.py | cut -d'"' -f2)
REPO_URL="https://nexus3.onap.org/repository/PyPi.staging/packages"
TAR_NAME="$REPO_URL/$PROJECT_NAME/$ARTIFACT_VERSION/$PROJECT_NAME-$ARTIFACT_VERSION.tar.gz"
WHEEL_NAME="${REPO_URL}/${PROJECT_NAME}/${ARTIFACT_VERSION}/${PROJECT_NAME}-${ARTIFACT_VERSION}-py2-none-any.whl"

mkdir dist
cd dist

wget ${TAR_NAME}
wget ${WHEEL_NAME}

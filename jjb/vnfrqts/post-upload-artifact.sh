#!/bin/bash

set -e -o pipefail
set -- $ARTIFACT_NAME
if [ -z "$ARTIFACT_NAME" ]
then
    echo "ERROR NO ARTIFACTS ENTERED"
else
    if [ -z "$2" ]
    then
        cd $WORKSPACE/docs/data
        echo "-n --upload-file $ARTIFACT_NAME https://nexus.onap.org/content/sites/raw/$PROJECT_ID/$GERRIT_BRANCH/$ARTIFACT_NAME"
        curl -n --upload-file "$ARTIFACT_NAME" "https://nexus.onap.org/content/sites/raw/$PROJECT_ID/$GERRIT_BRANCH/$ARTIFACT_NAME"
    else
        cd $WORKSPACE/ice_validator/output
        echo "-n --upload-file $1 https://nexus.onap.org/content/sites/raw/$PROJECT_ID/$GERRIT_BRANCH/$1"
        curl -n --upload-file "$1" "https://nexus.onap.org/content/sites/raw/$PROJECT_ID/$GERRIT_BRANCH/$1"
        echo "-n --upload-file $2 https://nexus.onap.org/content/sites/raw/$PROJECT_ID/$GERRIT_BRANCH/$2"
        curl -n --upload-file "$2" "https://nexus.onap.org/content/sites/raw/$PROJECT_ID/$GERRIT_BRANCH/$2"
    fi
fi
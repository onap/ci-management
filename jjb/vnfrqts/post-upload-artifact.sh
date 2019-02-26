#!/bin/bash

set -e -o pipefail
cd $WORKSPACE/docs/data
echo "-n --upload-file $ARTIFACT_NAME https://nexus.onap.org/content/sites/raw/$PROJECT_ID/$GERRIT_BRANCH/$ARTIFACT_NAME"
curl -n --upload-file "$ARTIFACT_NAME" "https://nexus.onap.org/content/sites/raw/$PROJECT_ID/$GERRIT_BRANCH/$ARTIFACT_NAME"
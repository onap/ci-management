#!/bin/bash

set -e -o pipefail
echo "-n --upload-file $ARTIFACT_NAME https://nexus.onap.org/content/sites/raw/$JOB_BASE_NAME/$GERRIT_BRANCH/$ARTIFACT_NAME"
curl -n --upload-file "$ARTIFACT_NAME" "https://nexus.onap.org/content/sites/raw/$JOB_BASE_NAME/$GERRIT_BRANCH/$ARTIFACT_NAME"
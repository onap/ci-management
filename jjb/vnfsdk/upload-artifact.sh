#!/bin/bash
set -e -o pipefail
if [ -z "$PROJECT_ID" ]
then
    echo "ERROR: NO PROJECT ID ENTERED"
    exit 1
else
    cd $WORKSPACE/generated/active-validation-rules/Honolulu/
    for FILE_NAME in *.csv ; do
        echo "-n --upload-file $FILE_NAME https://nexus.onap.org/content/sites/raw/$PROJECT_ID/$GERRIT_BRANCH/$FILE_NAME"
        curl -n --upload-file "$FILE_NAME" "https://nexus.onap.org/content/sites/raw/$PROJECT_ID/$GERRIT_BRANCH/$FILE_NAME"
    done
    exit 0
fi

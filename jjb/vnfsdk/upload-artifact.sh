#!/bin/bash
set -e -o pipefail
if [ -z "$PROJECT_ID" ]
then
    echo "ERROR: NO PROJECT ID ENTERED"
    exit 1
else
    cd $WORKSPACE/generated/active-validation-rules/Honolulu/
    for file in *.csv ; do
        echo "-n --upload-file $file https://nexus.onap.org/content/sites/raw/$PROJECT_ID/Honolulu/$file"
        curl -n --upload-file "$file" "https://nexus.onap.org/content/sites/raw/$PROJECT_ID/Honolulu/$file"
    done
    exit 0
fi

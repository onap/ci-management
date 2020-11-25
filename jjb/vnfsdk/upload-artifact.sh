#!/bin/bash
set -e -o pipefail
if [ -z "$PROJECT_ID" ]
then
    echo "ERROR: NO PROJECT ID ENTERED"
else
    cd $WORKSPACE/csarvalidation/target/generated-docs/Honolulu
    for file in *.csv ; do
        echo "-n --upload-file $file https://nexus.onap.org/content/sites/raw/$PROJECT_ID/$file"
        curl -n --upload-file "$file" "https://nexus.onap.org/content/sites/raw/$PROJECT_ID/$file"
    done
fi

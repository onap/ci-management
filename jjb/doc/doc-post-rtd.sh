#!/bin/bash
if [ "$GERRIT_BRANCH" == "master" ]; then
    RTD_BUILD_VERSION=latest
else
    RTD_BUILD_VERSION="${{GERRIT_BRANCH/\//-}}"
fi

# shellcheck disable=SC1083
curl -X POST \
    -d "branches=$RTD_BUILD_VERSION" \
    -d "token=$DOCS_RTD_TOKEN"  \
    https://readthedocs.org/api/v2/webhook/{rtdproject}

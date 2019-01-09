#!/bin/bash
if [ "$GERRIT_BRANCH" == "master" ]; then
    RTD_BUILD_VERSION=latest
else
    RTD_BUILD_VERSION="${{GERRIT_BRANCH/\//-}}"
fi

# shellcheck disable=SC1083
curl -X POST \
    -d "branches=$RTD_BUILD_VERSION" \
    -d "token=885ac10ffc59c32659d23ebdab371401a38e6fd3"  \
    https://readthedocs.org/api/v2/webhook/onap/58810/

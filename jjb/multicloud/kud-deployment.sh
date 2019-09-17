#!/bin/bash

set -x -e -o pipefail
cd ./kud/ci

export KUD_PLUGIN_ENABLED=false
export KUD_ENABLE_TESTS=true
export KUD_ADDONS='virtlet'

#Increase logs verbosity
git fetch "https://gerrit.onap.org/r/multicloud/k8s" refs/changes/22/93022/5 && git cherry-pick FETCH_HEAD

bash -x ./kud-installer.sh

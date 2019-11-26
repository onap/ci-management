#!/bin/bash

set -x -e -o pipefail
cd ./kud/ci
export KUD_ENABLE_TESTS=true
export KUD_PLUGIN_ENABLED=true
bash -x ./kud-installer.sh

#!/usr/bin/env	bash

# setting-up bash flags
set -x -e -o pipefail

# run all-in-one deployment
cd ./kud/ci
sudo bash -x ./kud-installer.sh

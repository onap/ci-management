#!/usr/bin/env	bash

# setting-up bash flags
set -x -e -o pipefail

# run all-in-one deployment
cd ./kud/hosting_providers/vagrant
sudo bash -x ./aio.sh

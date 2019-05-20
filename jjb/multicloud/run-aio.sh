#!/bin/bash

# setting-up bash flags
set -x -e -o pipefail

# run all-in-one deployment
cd ./kud/hosting_providers/vagrant
sudo ./aio.sh

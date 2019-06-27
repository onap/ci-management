#!/bin/bash

set -x -e -o pipefail
cd ./kud/ci
bash -x ./kud-installer.sh

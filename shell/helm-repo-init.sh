#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

# client only init, tiller will not be installed
helm init --client-only
cd kubernetes/ || exit
make repo
cd ..

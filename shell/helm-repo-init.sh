#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

# client only init, tiller will not be installed
helm init --client-only
cd kubernetes/ || exit
make repo
cd ..
mkdir -p ".chartstorage"
chartmuseum --port=6464 --storage="local" --storage-local-rootdir=".chartstorage" &
helm3 plugin install https://github.com/chartmuseum/helm-push.git
helm3 repo add local http://localhost:6464

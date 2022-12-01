#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

mkdir -p ".chartstorage"

chartmuseum --port=6464 --storage="local" --storage-local-rootdir=".chartstorage" &> /dev/null &
source helm.prop
helm plugin install --version v0.10.3 https://github.com/chartmuseum/helm-push.git || true
helm repo add local http://localhost:6464
helm repo add onap http://localhost:6464

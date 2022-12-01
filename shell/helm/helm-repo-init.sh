#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

mkdir -p ".chartstorage"

chartmuseum --port=6464 --storage="local" --storage-local-rootdir=".chartstorage" &> /dev/null &
$HELM_BIN plugin install --version v0.10.3 https://github.com/chartmuseum/helm-push.git || true
$HELM_BIN repo add local http://localhost:6464
$HELM_BIN repo add onap http://localhost:6464

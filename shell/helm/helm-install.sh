#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

echo "Installing helm ${HELM_VER}"
mkdir /tmp/helm"${HELM_VER}"
cd /tmp/helm"${HELM_VER}"
wget "https://get.helm.sh/helm-v${HELM_VER}-linux-amd64.tar.gz"
tar xvf helm-v"${HELM_VER}"-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm"${HELM_VER}"
which helm"${HELM_VER}"
cd ~/
echo "Completed install of helm ${HELM_VER}"


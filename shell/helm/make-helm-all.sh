#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail
cd kubernetes/
make HELM_BIN=$HELM_BIN all -j2

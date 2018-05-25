#!/bin/bash
# Ensure we fail the job if any steps fail
set -e -o pipefail

helm init
cd kubernetes/ || exit
make repo
cd ..

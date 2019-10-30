#!/bin/bash -l
echo "---> run_releasedockerhub.sh"
_ORG=$1
_SUMMARY=$2
_VERBOSE=$3
_COPY=$4
# Ensure we fail the job if any steps fail
# Disable 'globbing'
set -euf -o pipefail

# Run the releasedockerhub command in lftools
lftools nexus docker releasedockerhub --org $_ORG $_SUMMARY $_VERBOSE $_COPY


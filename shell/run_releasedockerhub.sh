#!/bin/bash -l
echo "---> run_releasedockerhub.sh"
# Ensure we fail the job if any steps fail
# Disable 'globbing'
set -euf -o pipefail

if [ ! -v RELEASEDOCKERHUB_ORG ]
then
  echo "RELEASEDOCKERHUB_ORG is not defined. For onap set it to 'onap'"
  exit 1
fi

cmd_str="--org $RELEASEDOCKERHUB_ORG"
if [ -v RELEASEDOCKERHUB_SUMMARY ]
then
    cmd_str+=" --summary"
fi
if [ -v RELEASEDOCKERHUB_VERBOSE ]
then
    cmd_str+=" --verbose"
fi
if [ -v RELEASEDOCKERHUB_REPO ]
then
    cmd_str+=" --repo $RELEASEDOCKERHUB_REPO"
fi

if [ -v RELEASEDOCKERHUB_COPY ]
then
    cmd_str+=" --copy"
fi

echo "cmd_str = >>$cmd_str<<"

# Run the releasedockerhub command in lftools
lftools nexus docker releasedockerhub  $cmd_str



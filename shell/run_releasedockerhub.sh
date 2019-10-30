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

#echo "RELEASEDOCKERHUB_ORG = >>$RELEASEDOCKERHUB_ORG<<"

cmd_str="--org $RELEASEDOCKERHUB_ORG"
if [ -v RELEASEDOCKERHUB_SUMMARY ]
then
#    echo "RELEASEDOCKERHUB_SUMMARY = >>$RELEASEDOCKERHUB_SUMMARY<<"
    cmd_str+=" --summary"
fi
if [ -v RELEASEDOCKERHUB_VERBOSE ]
then
#    echo "RELEASEDOCKERHUB_VERBOSE = >>$RELEASEDOCKERHUB_VERBOSE<<"
    cmd_str+=" --verbose"
fi
if [ -v RELEASEDOCKERHUB_REPO ]
then
#    echo "RELEASEDOCKERHUB_REPO = >>$RELEASEDOCKERHUB_REPO<<"
    cmd_str+=" --repo $RELEASEDOCKERHUB_REPO"
fi

if [ -v RELEASEDOCKERHUB_COPY ]
then
#    echo "RELEASEDOCKERHUB_COPY = >>$RELEASEDOCKERHUB_COPY<<"
    cmd_str+=" --copy"
fi


#if [ ! -n "{$RELEASEDOCKERHUB_VERBOSE:-}" ] 
#then
#  echo "RELEASEDOCKERHUB_VERBOSE empty"
#fi
#if [ ! -n "{$RELEASEDOCKERHUB_ORG:-}" ] 
#then
#  echo "RELEASEDOCKERHUB_ORG empty"
#else
#  echo "RELEASEDOCKERHUB_ORG NOT empty"
#fi



echo "cmd_str = >>$cmd_str<<"

# Run the releasedockerhub command in lftools
lftools nexus docker releasedockerhub  $cmd_str



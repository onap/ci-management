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

CMD_STR="--org $RELEASEDOCKERHUB_ORG"
if [ -v RELEASEDOCKERHUB_SUMMARY ]
then
#    echo "RELEASEDOCKERHUB_SUMMARY = >>$RELEASEDOCKERHUB_SUMMARY<<"
    CMD_STR="$CMD_STR --summary"
fi
if [ -v RELEASEDOCKERHUB_VERBOSE ]
then
#    echo "RELEASEDOCKERHUB_VERBOSE = >>$RELEASEDOCKERHUB_VERBOSE<<"
    CMD_STR="$CMD_STR --verbose"
fi
if [ -v RELEASEDOCKERHUB_COPY ]
then
#    echo "RELEASEDOCKERHUB_COPY = >>$RELEASEDOCKERHUB_COPY<<"
    CMD_STR="$CMD_STR --copy"
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



echo "CMD_STR = >>$CMD_STR<<"

# Run the releasedockerhub command in lftools
lftools nexus docker releasedockerhub  $CMD_STR



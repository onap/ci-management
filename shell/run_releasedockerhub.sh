#!/bin/bash -l
echo "---> run_releasedockerhub.sh"
# Ensure we fail the job if any steps fail
# Disable 'globbing'
#set -euf -o pipefail
set -ef -o pipefail

#set -x

if [ -z "$RELEASEDOCKERHUB_ORG" ]
then
  echo "RELEASEDOCKERHUB_ORG is not defined. For onap set it to 'onap'"
  exit 1
fi

CMD_STR="--org $RELEASEDOCKERHUB_ORG"
if [ ! -z "$RELEASEDOCKERHUB_SUMMARY" ] 
then 
    CMD_STR="$CMD_STR --summary"
fi
if [ ! -z "$RELEASEDOCKERHUB_VERBOSE" ] 
then 
    CMD_STR="$CMD_STR --verbose"
fi
if [ ! -z "$RELEASEDOCKERHUB_COPY" ] 
then 
    CMD_STR="$CMD_STR --copy"
fi

echo "RELEASEDOCKERHUB_ORG = >>$RELEASEDOCKERHUB_ORG<<"
echo "RELEASEDOCKERHUB_SUMMARY = >>$RELEASEDOCKERHUB_SUMMARY<<"
echo "RELEASEDOCKERHUB_VERBOSE = >>$RELEASEDOCKERHUB_VERBOSE<<"
echo "RELEASEDOCKERHUB_COPY = >>$RELEASEDOCKERHUB_COPY<<"
echo "CMD_STR = >>$CMD_STR<<"

# Run the releasedockerhub command in lftools
lftools nexus docker releasedockerhub  $CMD_STR



#!/bin/bash

DOCKER_REPOSITORIES=nexus3.openecomp.org:10001 \
                   nexus3.openecomp.org:10002 \
                   nexus3.openecomp.org:10003

for DOCKER_REPOSITORY in $DOCKER_REPOSITORIES;
do
    USER=$(xpath -q -e "//servers/server[id='$DOCKER_REPOSITORY']/username/text()" "$SETTINGS_FILE")
    PASS=$(xpath -q -e "//servers/server[id='$DOCKER_REPOSITORY']/password/text()" "$SETTINGS_FILE")
    docker login $DOCKER_REPOSITORY -u $USER -p $PASS
done

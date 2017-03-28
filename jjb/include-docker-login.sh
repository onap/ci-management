#!/bin/bash

# vim: ts=4 sw=4 sts=4 et :

DOCKER_REPOSITORIES="nexus3.onap.org:10001 \
                   nexus3.onap.org:10002 \
                   nexus3.onap.org:10003 \
                   nexus3.onap.org:10004"

for DOCKER_REPOSITORY in $DOCKER_REPOSITORIES;
do
    echo $DOCKER_REPOSITORY
    USER=$(xpath -e "//servers/server[id='$DOCKER_REPOSITORY']/username/text()" "$SETTINGS_FILE")
    PASS=$(xpath -e "//servers/server[id='$DOCKER_REPOSITORY']/password/text()" "$SETTINGS_FILE")

    if [ -z "$USER" ];
    then
        echo "Error: no user provided"
    fi

    if [ -z "$PASS" ];
    then
        echo "Error: no password provided"
    fi

    [ -z "$PASS" ] && PASS_PROVIDED="<empty>" || PASS_PROVIDED="<password>"
    echo docker login $DOCKER_REPOSITORY -u "$USER" -p "$PASS_PROVIDED"
    docker login $DOCKER_REPOSITORY -u "$USER" -p "$PASS"
done

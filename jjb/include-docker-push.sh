#!/bin/bash

DOCKER_REPOSITORY="nexus3.openecomp.org:10003"
SEARCH="aai-service";

if [[ $PROJECT =~ $SEARCH ]] ; then
    docker push $DOCKER_REPOSITORY/ecomp/ajsc-aai:latest;
else
    docker push $DOCKER_REPOSITORY/ecomp/model-loader:latest;
fi

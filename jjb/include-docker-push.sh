#!/bin/bash

DOCKER_REPOSITORY="nexus3.openecomp.org:10003"
SEARCH="aai-service";

if [[ $PROJECT =~ $SEARCH ]] ; then
    docker push $DOCKER_REPOSITORY/openecomp/ajsc-aai:latest;
else
    # Cut the prefix aai/ in example aai/model-loader
    DOCKER_REPO_NAME=$(echo ${PROJECT} | cut -d"/" -f2-);
    docker push $DOCKER_REPOSITORY/openecomp/${DOCKER_REPO_NAME}:latest;
fi

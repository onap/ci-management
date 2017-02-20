#!/bin/bash

DOCKER_REPOSITORY="nexus3.openecomp.org:10003"
SEARCH="aai-service";

[[ $PROJECT =~ $SEARCH ]] && docker push $DOCKER_REPOSITORY/ajsc-aai:latest || docker push $DOCKER_REPOSITORY/ecomp/model-loader:latest

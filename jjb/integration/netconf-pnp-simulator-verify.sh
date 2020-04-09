#!/bin/bash

# Copyright 2020 Samsung Electronics Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Script verifies if all services in Netconf simulator's docker
# service container were launched successfully.

echo "---> netconf-pnp-simulator-verify.sh"

set -e # Exit with zero only if all commands succeed

DOCKER_COMPOSE_LOG="/tmp/docker-compose.log"
DOCKER_COMPOSE_LOG_MSG=( "success:" "entered RUNNING state" )
DOCKER_COMPOSE_SLEEP_INTERVAL=60

if [ -z ${NETCONF_SIM_SERVICE_NAME} ];
then
    echo "ERROR: netconf-pnp-simulator service name not set."
    exit 1
fi

pushd $DOCKER_ROOT

# Dump container logs
sleep ${DOCKER_COMPOSE_SLEEP_INTERVAL} # Hang for a while so the services settle
docker-compose logs --no-color > ${DOCKER_COMPOSE_LOG}

# Get the supervisord services running within container
supervisord_services=($(docker-compose exec -T ${NETCONF_SIM_SERVICE_NAME} /bin/sh -c \
    'cat /etc/supervisord.conf /etc/supervisord.d/*' | grep -ho "program:[-a-zA-Z0-9]*" | cut -d: -f 2))

# Check all services are running and fail if not
for service in ${supervisord_services[@]};
do
    if ! grep -q "${DOCKER_COMPOSE_LOG_MSG[0]} $service ${DOCKER_COMPOSE_LOG_MSG[1]}" ${DOCKER_COMPOSE_LOG};
    then
        echo "ERROR: Service $service is not running, failing the build."
        exit 1
    fi
done

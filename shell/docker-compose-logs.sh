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

# Dump Docker Compose info

set +e  # Do not fail build if any of script command fails
set -x

echo "---> docker-compose-logs.sh"

cd $DOCKER_ROOT
docker-compose config
docker-compose ps
docker-compose top
docker-compose images

# Do not fail build if script fails.
exit 0

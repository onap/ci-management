#!/bin/bash

# ================================================================================
# Copyright (c) 2019 AT&T Intellectual Property. All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END=========================================================

set -feu -o pipefail

echo "--> docker-ts-tag-override.sh"
# Get project version from pom.xml
version=`xmllint --xpath "//*[local-name()='project']/*[local-name()='version']/text()" $DOCKER_ROOT/pom.xml`

# Get build TS for specifying in the tag
timestamp=$(date +%C%y%m%dT%H%M%SZ)

# Following the https://wiki.onap.org/display/DW/Independent+Versioning+and+Release+Process
# IndependentVersioningandReleaseProcess-StandardizedDockerTagging
# ONAP Tag requirement :  {imagename}:{semver}-SNAPSHOT-{timestamp}Z (from CIMAN-132)


if [ "$version" == "" ]; then
  version=latest
  tag="${version}-${timestamp}"
else
  tag="${version}-SNAPSHOT-${timestamp}"
fi

echo "DOCKER TAG:" $tag

# Write DOCKER_IMAGE_TAG information to a file so it can be
# injected into the environment for following steps
echo "DOCKER_IMAGE_TAG=$tag" >> "$WORKSPACE/env_docker_inject.txt"

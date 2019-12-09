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

# Get project version from pom.xml
VERSION=`xmllint --xpath "//*[local-name()='project']/*[local-name()='version']/text()" $DOCKER_ROOT/pom.xml`

# Get build TS for specifying in the tag
TIMESTAMP=$(date +%C%y%m%dT%H%M%S)

# Following the https://wiki.onap.org/display/DW/Independent+Versioning+and+Release+Process
# IndependentVersioningandReleaseProcess-StandardizedDockerTagging
# ONAP Tag requirement :  {imagename}:{semver}-SNAPSHOT-{timestamp}Z       this is what CIMAN-132 asks


if [ "$VERSION" == "" ]; then
	VERSION=latest
	TAG="${VERSION}-${TIMESTAMP}"Z
else
	TAG="${VERSION}-SNAPSHOT-${TIMESTAMP}"Z	
fi

echo "VERSION:" $VERSION
echo "DOCKER TAG:" $TAG

# Write DOCKER_IMAGE_TAG information to a file so it can be 
# injected into the environment for following steps 
echo "DOCKER_IMAGE_TAG=$TAG" >> "$WORKSPACE/env_docker_inject.txt" 

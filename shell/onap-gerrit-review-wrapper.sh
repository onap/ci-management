#!/bin/sh

# ================================================================================
# Copyright (c) 2022 AT&T Intellectual Property. All rights reserved.
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

set -eu

echo "--> onap-gerrit-review-wrapper.sh"

# Cleanup temporary directory if exist
rm -Rf /tmp/ogr

# Create temporary directory to clone OGR repository
mkdir /tmp/ogr
cd  /tmp/ogr
git init
git clone https://github.com/TonyLHansen/onap-gerrit-review.git

# Add OGR/bin to PATH
export PATH=$PATH:/tmp/ogr/onap-gerrit-review/bin

# Revert back to original patchset directory
# TO DO - replace . with env/property specifying the exact path of latest patchset
cd $WORKSPACE

# Execute OGR
onap-gerrit-review .


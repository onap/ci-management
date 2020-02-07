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

echo "---> vagrantfile-verify.sh"

set -e

declare -a CHANGED_VAGRANTFILES
CMD='vagrant validate'

CHANGED_VAGRANTFILES=(`git diff HEAD^ HEAD --name-only "*Vagrantfile"`)

for v_dir in ${CHANGED_VAGRANTFILES[@]};
do
  echo "---> Validating ./$v_dir"
  pushd $(dirname $v_dir)
  eval "$CMD"
  popd
done

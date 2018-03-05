#!/bin/bash
# Copyright 2018 ZTE Corporation.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

run_tox_test() 
{ 
  echo "========== CALLING SCRIPT TO EXEC TOX ============="
  set -x
  CURDIR=$(pwd)
  echo "====Current directory is ${CURDIR}"
  TOXINIS=$(find . -name "tox.ini")
  for TOXINI in "${TOXINIS[@]}"; do
    DIR=$(echo "$TOXINI" | rev | cut -f2- -d'/' | rev)
    echo "====Found tox.ini in ${DIR}===="
    cd "${CURDIR}/${DIR}"
    rm -rf ./venv-tox ./.tox
    virtualenv ./venv-tox
    source ./venv-tox/bin/activate
    pip install --upgrade pip
    pip install --upgrade tox argparse
    pip freeze
    tox
    deactivate
    rm -rf ./venv-tox ./.tox
  done
}

run_tox_test

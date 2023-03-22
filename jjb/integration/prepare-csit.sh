#!/bin/bash -x
#
# Copyright 2019-2021 Samsung Electronics Co., Ltd.
# Modifications Copyright (C) 2021 Pantheon.tech
#
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
#
# This script installs common libraries required by CSIT tests
#

echo "---> prepare-csit.sh"

set -exo pipefail

ROBOT_INSTALLER='include-raw-integration-install-robotframework-py3.sh'

# Allows testing for root permissions
REQ_USER=$(id -un)

if ! (which git > /dev/null 2>&1); then
    echo "GIT binary not found in current PATH"
    # Add missing package to prevent script/job failures
    if (grep Ubuntu /etc/os-release > /dev/null 2>&1) || \
    (grep Debian /etc/os-release > /dev/null 2>&1); then
        echo "Installing package dependency for Ubuntu/Debian"
        if [[ "${REQ_USER}" == 'root' ]]; then
            apt-get update
            apt-get install -y git
        else
            sudo apt-get update
            sudo apt-get install -y git
        fi
    elif (grep RedHat /etc/os-release > /dev/null 2>&1) || \
    (grep CentOS /etc/os-release > /dev/null 2>&1); then
        echo "Installing package dependency for CentOS/RedHat"
        if [[ "${REQ_USER}" == 'root' ]]; then
            yum install -y git
        else
            sudo yum install -y git
        fi
    else
        echo "Warning: unmatched OS/distribution"
        echo "Missing software will not be installed"
    fi
fi

if [[ -z "${WORKSPACE}" ]]; then
    if (git rev-parse --show-toplevel > /dev/null 2>&1); then
        WORKSPACE=$(git rev-parse --show-toplevel)
        export WORKSPACE
    else
        WORKSPACE=$(pwd)
        export WORKSPACE
    fi
fi

# shellcheck disable=SC2034
TESTPLANDIR="${WORKSPACE}/${TESTPLAN}"

# Python version should match that used to setup
#  robot-framework in other jobs/stages
# Use pyenv for selecting the python version
if [[ -d "/opt/pyenv" ]]; then
    echo "Setup pyenv:"
    export PYENV_ROOT="/opt/pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    pyenv versions
    if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init - --no-rehash)"
        # Choose the latest numeric Python version from installed list
        version=$(pyenv versions --bare | sed '/^[^0-9]/d' \
            | sort -V | tail -n 1)
        pyenv local "${version}"
    fi
fi

# Assume that if ROBOT3_VENV is set, virtualenv
#  with system site packages can be activated
if [[ -f "${WORKSPACE}/env.properties" ]]; then
    source "${WORKSPACE}/env.properties"
elif [[ -f /tmp/env.properties ]]; then
    source /tmp/env.properties
fi

if [[ -f "${ROBOT3_VENV}/bin/activate" ]]; then
    source "${ROBOT3_VENV}/bin/activate"
else
    # Robot framework was not found
    #  Clone/update ci-management repository and invoke install script
    if [[ ! -d /tmp/ci-management ]]; then
        git clone "https://gerrit.onap.org/r/ci-management" \
        /tmp/ci-management
    else
        git pull /tmp/ci-management
    fi
    # shellcheck disable=SC1090
    source "/tmp/ci-management/jjb/integration/${ROBOT_INSTALLER}"
fi

# install eteutils
mkdir -p "${ROBOT3_VENV}/src/onap"
rm -rf "${ROBOT3_VENV}/src/onap/testsuite"
# Source from the Nexus repository
python3 -m pip install --upgrade \
    --extra-index-url="https://nexus3.onap.org/repository/PyPi.staging/simple" \
    'robotframework-onap==11.0.0.dev17' \
    --pre

echo "Versioning information:"
python3 --version
pip freeze
python3 -m robot.run --version || :


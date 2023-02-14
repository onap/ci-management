#!/bin/bash -l
# SPDX-License-Identifier: EPL-1.0
##############################################################################
# Copyright (c) 2022 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################
# vim: sw=4 ts=4 sts=4 et ft=sh :

set -euxo pipefail

echo "---> install-robotframework-py3.sh"

### Common variables

REQUIRED_PYTHON="3.7.0"

### Common functions

# Allows for the comparison of two Python version strings
ver_cmp()
{
    local IFS=.
    # shellcheck disable=SC2206
    local V1=($1) V2=($2) I
    for ((I=0 ; I<${#V1[*]} || I<${#V2[*]} ; I++)) ; do
        [[ ${V1[$I]:-0} -lt ${V2[$I]:-0} ]] && echo -1 && return
        [[ ${V1[$I]:-0} -gt ${V2[$I]:-0} ]] && echo 1 && return
    done
    echo 0
}
# Checks if first version/string is greater than or equal to the second
ver_ge()
{
    [[ ! $(ver_cmp "$1" "$2") -eq -1 ]]
}

### Main script entry point

# Check for required Python versions and activate/warn appropriately
# Use PYENV for selecting the latest python version, if available
if [[ -d "/opt/pyenv" ]]; then
    echo "Setup pyenv:"
    export PYENV_ROOT="/opt/pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    pyenv versions
    if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init - --no-rehash)"
        # Choose the latest numeric Python version from installed list
        version=$(pyenv versions --bare | sed '/^[^0-9]/d' |\
            sort -V | tail -n 1)
        pyenv local "${version}"
    fi
fi

# Store the active/current Python3 version
PYTHON_VERSION=$(python3 --version | awk '{print $2}')

#  Check that the required minimum version has been met
if ! (ver_ge "${PYTHON_VERSION}" "${REQUIRED_PYTHON}"); then
    echo "Warning: possible Python version problem"
    echo "Python ${PYTHON_VERSION} does not meet requirement: ${REQUIRED_PYTHON}"
fi

if (python3 -m robot.run --version > /dev/null 2>&1); then
    echo "Working robot framework found; no installation necessary"
    echo "Installed under Python version: ${PYTHON_VERSION}"
    exit 0
fi


# Create a requirements file; keep it around for potential later use
# Versions and dependencies below have been carefully tested for Python3
cat << 'EOF' > "requirements.txt"
paramiko
six
urllib3
docker-py
ipaddr
netaddr
netifaces
pyhocon
requests
selenium<4.6.0,>=4.0.0
robotframework
robotframework-httplibrary
robotframework-requests==0.9.3
robotframework-selenium2library
robotframework-sshlibrary
scapy
# Module jsonpath is needed by current AAA idmlite suite.
jsonpath-rw
# Modules for longevity framework robot library
elasticsearch<8.0.0,>=7.0.0
elasticsearch-dsl
# Module for pyangbind used by lispflowmapping project
pyangbind
# Module for iso8601 datetime format
isodate
# Module for TemplatedRequests.robot library
jmespath
# Module for backup-restore support library
jsonpatch
pbr
deepdiff
dnspython
future
jinja2
kafka-python
# Protobuf requires Python >=3.7
protobuf
pyyaml
robotlibcore-temp
more-itertools
xvfbwrapper
PyVirtualDisplay
# Additional package dependencies for ONAP project
# odltools for extra debugging
# Generates warning:
# ERROR: odltools 0.1.34 has requirement requests~=2.19.1,
#  but you'll have requests 2.28.1 which is incompatible.
odltools
EOF


if [[ -f ~/lf-env.sh ]]; then
    echo "Installing robot-framework using LF common tooling"
    # shellcheck disable=SC1090
    source ~/lf-env.sh

    # Create a virtual environment for robot tests and make sure setuptools & wheel
    # are up-to-date in addition to pip
    lf-activate-venv --python python3 --venv-file "${WORKSPACE}/.robot3_venv" \
    setuptools \
    pip \
    wheel

    # Install the robot framework and other dependencies
    python3 -m pip install -r requirements.txt

    # Save the virtual environment in ROBOT3_VENV
    ROBOT3_VENV="$(cat "${WORKSPACE}/.robot3_venv")"

else
    echo "Installing robot-framework in a virtual environment"
    if [[ -z "${WORKSPACE}" ]]; then
        # Use a temporary folder location
        WORKSPACE="/tmp"
        ROBOT3_VENV=$(mktemp -d --suffix=-robot3_venv)
    else
        ROBOT3_VENV="${WORKSPACE}/.robot3_venv"
    fi

    # The --system-site-packages parameter allows us to pick up system level
    # installed packages. This allows us to bake matplotlib which takes very long
    # to install into the image.
    python3 -m venv --system-site-packages "${ROBOT3_VENV}"
    source "${ROBOT3_VENV}/bin/activate"

    echo "Installing robot-framework using basic methods"
    python3 -m pip install -r requirements.txt
fi

# Store the virtual environment location
echo "ROBOT3_VENV=${ROBOT3_VENV}" >> "${WORKSPACE}/env.properties"

# Display versioning/debugging output
python3 --version
python3 -m pip freeze
python3 -m robot.run --version || :

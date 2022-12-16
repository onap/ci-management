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

set -eu pipefail

# shellcheck disable=SC1090
. ~/lf-env.sh

# Create a virtual environment for robot tests and make sure setuptools & wheel
# are up-to-date in addition to pip
lf-activate-venv --python python3 --venv-file "${WORKSPACE}/.robot3_venv" \
    setuptools \
    wheel

# Save the virtual environment in ROBOT_VENV
ROBOT3_VENV="$(cat "${WORKSPACE}/.robot3_venv")"
echo ROBOT3_VENV="${ROBOT3_VENV}" >> "${WORKSPACE}/env.properties"

set -exu

echo "Installing Python Requirements"
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

python3 -m pip install -r requirements.txt
python3 -m pip freeze
python3 -m robot.run --version || :

if [ ! -z ${ROBOT3_VENV}]; then
    export ${ROBOT3_VENV}
fi


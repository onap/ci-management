#!/bin/bash

##############################################################################
# Copyright (c) 2016 The Linux Foundation and others.
##############################################################################

ROBOT3_VENV=$(mktemp -d --suffix=robot3_venv)
echo "ROBOT3_VENV=${ROBOT3_VENV}" >> "${WORKSPACE}/env.properties"

# The --system-site-packages parameter allows us to pick up system level
# installed packages. This allows us to bake matplotlib which takes very long
# to install into the image.
virtualenv --system-site-packages "${ROBOT3_VENV}"
source "${ROBOT3_VENV}/bin/activate"

set -exu

# Make sure pip itself us up-to-date.
pip3 install --upgrade pip

pip3 install --no-binary pycparser cffi setuptools-rust
pip3 install pyOpenSSL docker-py importlib requests scapy netifaces netaddr ipaddr simplejson demjson
pip3 install robotframework-httplibrary robotframework-requests robotframework-sshlibrary robotframework-selenium2library robotframework-xvfb

pip3 install xvfbwrapper
pip3 install PyVirtualDisplay

# Print installed versions.
pip3 freeze

# Check robot module is available and working
python3 -m robot.run --version

# vim: sw=4 ts=4 sts=4 et ft=sh :

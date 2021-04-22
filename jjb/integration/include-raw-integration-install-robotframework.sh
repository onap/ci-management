#!/bin/bash

##############################################################################
# Copyright (c) 2016 The Linux Foundation and others.
##############################################################################

ROBOT_VENV=$(mktemp -d --suffix=robot_venv)
echo "ROBOT_VENV=${ROBOT_VENV}" >> "${WORKSPACE}/env.properties"

# The --system-site-packages parameter allows us to pick up system level
# installed packages. This allows us to bake matplotlib which takes very long
# to install into the image.
virtualenv --system-site-packages "${ROBOT_VENV}"
source "${ROBOT_VENV}/bin/activate"

set -exu

# Make sure pip itself us up-to-date.
pip install --upgrade pip

pip install --no-binary pycparser==2.20 pycparser==2.20
pip install pyOpenSSL==16.2.0 docker-py==1.10.6 importlib==1.0.4 requests==2.25.1 scapy==2.4.4 netifaces==0.10.9 netaddr==0.8.0 ipaddr==2.2.0 simplejson==3.17.2 demjson==2.2.4
pip install robotframework-httplibrary==0.4.2 robotframework-requests==0.8.2 robotframework-sshlibrary==3.6.0 robotframework-selenium2library==1.8.0 robotframework-xvfb==1.2.2

pip install xvfbwrapper==0.2.9
pip install PyVirtualDisplay==2.1

# Print installed versions.
pip freeze

# vim: sw=4 ts=4 sts=4 et ft=sh :

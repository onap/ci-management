#!/bin/bash

##############################################################################
# Copyright (c) 2016 The Linux Foundation and others.
##############################################################################

ROBOT_VENV=`mktemp -d --suffix=robot_venv`
echo ROBOT_VENV=${ROBOT_VENV} >> ${WORKSPACE}/env.properties

# The --system-site-packages parameter allows us to pick up system level
# installed packages. This allows us to bake matplotlib which takes very long
# to install into the image.
virtualenv --system-site-packages ${ROBOT_VENV}
source ${ROBOT_VENV}/bin/activate

set -exu

# Make sure pip itself us up-to-date.
pip install --upgrade pip

pip install --upgrade --no-binary pycparser pycparser
pip install --upgrade docker-py importlib requests scapy netifaces netaddr ipaddr simplejson demjson
pip install --upgrade robotframework{,-{httplibrary,requests,sshlibrary,selenium2library}}

# Print installed versions.
pip freeze

# vim: sw=4 ts=4 sts=4 et ft=sh :

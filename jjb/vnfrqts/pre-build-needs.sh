#!/bin/bash

virtualenv $WORKSPACE/venv-tox
source $WORKSPACE/venv-tox/bin/activate
pip install --upgrade pip
pip install -r etc/requirements.txt
ls
wget -O $WORKSPACE/docs/data/needs.json "https://nexus.onap.org/content/sites/raw/org.onap.vnfrqts.requirements/master/needs.json"
tox -e needs
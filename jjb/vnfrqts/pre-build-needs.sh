#!/bin/bash

virtualenv -p python3.6 $WORKSPACE/venv-tox
source $WORKSPACE/venv-tox/bin/activate
pip install --upgrade pip
pip install -r etc/requirements.txt
ls
wget -O docs/data/needs.json "https://nexus.onap.org/content/sites/raw/org.onap.vnfrqts.requirements/master/needs.json" && echo "Copied newest needs." || exit 1
tox -e needs
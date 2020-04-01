#!/bin/bash

python3 -m venv $WORKSPACE/venv-tox
source $WORKSPACE/venv-tox/bin/activate
pip3 install --upgrade pip
pip3 install --no-use-pep517 -r requirements.txt
ls
wget -O $WORKSPACE/ice_validator/heat_requirements.json "https://nexus.onap.org/content/sites/raw/org.onap.vnfrqts.requirements/master/needs.json" && echo "Copied newest needs." || exit 1
cd ice_validator/
pytest --self-test tests/
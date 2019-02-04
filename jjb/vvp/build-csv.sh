#!/bin/bash
virtualenv -p python3 $WORKSPACE/venv-tox
source $WORKSPACE/venv-tox/bin/activate
pip3 install --upgrade pip
pip3 install --no-use-pep517 -r requirements.txt
ls
cd ice_validator/
pytest --self-test tests/

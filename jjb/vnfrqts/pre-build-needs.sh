#!/bin/bash

virtualenv $WORKSPACE/venv-tox
source $WORKSPACE/venv-tox/bin/activate
pip install --upgrade pip
pip install -r etc/requirements.txt
ls
tox -e needs
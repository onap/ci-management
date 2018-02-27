#!/bin/bash
# Script to build PyPI artifacts
set -e -x -o pipefail

virtualenv /tmp/v/twine
source "/tmp/v/twine/bin/activate"

pip install twine wheel

python setup.py sdist bdist_wheel

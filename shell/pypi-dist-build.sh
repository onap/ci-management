#!/bin/bash
# Script to build PyPI artifacts
set -e -x -o pipefail

virtualenv -p "$PYTHON_VERSION" /tmp/v/twine
source "/tmp/v/twine/bin/activate"

pip install twine wheel

cd "$WORKSPACE/$TOX_DIR"
python setup.py sdist bdist_wheel

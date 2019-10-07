#!/bin/bash
# Script to publush PyPI artifacts
set -e -x -o pipefail

virtualenv -p "$PYTHON" /tmp/v/twine
source "/tmp/v/twine/bin/activate"

pip install twine

cd "$WORKSPACE/$TOX_DIR"
twine upload -r $PYPI_SERVER dist/*

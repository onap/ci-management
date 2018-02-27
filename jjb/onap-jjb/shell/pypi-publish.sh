#!/bin/bash
# Script to publush PyPI artifacts
set -e -x -o pipefail

virtualenv /tmp/v/twine
source "/tmp/v/twine/bin/activate"

pip install twine

twine upload -r $PYPI_SERVER dist/*

#!/bin/bash

cd $WORKSPACE/csarvalidation/python/
virtualenv -p python3 ./venv
source ./venv/bin/activate
pip install --upgrade pip
pip install -r ./requirements.txt

cd ./main
export OUTPUT_DIRECTORY="$WORKSPACE/generated/active-validation-rules/Honolulu/"
python3 ./generate_active_validation_rules_table.py

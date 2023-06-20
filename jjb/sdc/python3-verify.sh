#!/bin/bash

py_files=$(find . -name '*.py' -not -path "*/node_modules/*" -not -path "*/target/*")

if python3 -m py_compile ${py_files}
then
    echo "All python files compiled successfully"
    exit 0
else
    echo "Failed to compile all files in Python 3"
    exit 1
fi

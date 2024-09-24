#!/bin/sh

echo "Cloning"
git clone https://gerrit.o-ran-sc.org/r/nonrtric /tmp/nonrtric
echo "after Cloning copy"
cp -r /tmp/nonrtric "$WORKSPACE"
echo "After copy"
./"$WORKSPACE"/test/auto-test/verify-jobs-nonrtric.sh

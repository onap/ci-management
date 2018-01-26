#!/bin/bash -x
echo Job triggered by $SRC_BUILD_URL
echo Retriving logs from $LOG_DIR_URL

rm -rf archives
wget -r -nv -nd --no-parent -l 1 --reject="index.html*" -P archives "$LOG_DIR_URL"
cat archives/console.log

#!/bin/bash
set -xe -o pipefail

echo Job triggered by $SRC_BUILD_URL
echo Retriving logs from $LOG_DIR_URL

rm -rf archives
mkdir -p archives
curl -f "$SRC_BUILD_URL/timestamps/?time=HH:mm:ssZ&appendLog" > archives/console-source-timestamp.log
wget -r -nv -nd --no-parent -l 1 --reject="index.html*" -P archives "$LOG_DIR_URL"
if [ -s archives/console-source-timestamp.log ]; then
    cat archives/console-source-timestamp.log
else
    cat archives/console.log
fi

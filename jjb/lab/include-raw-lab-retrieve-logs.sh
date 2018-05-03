#!/bin/bash
set -xe -o pipefail

echo Job triggered by $SRC_BUILD_URL
echo Retriving logs from $LOG_DIR_URL

rm -rf archives
wget -r -nv -nd --no-parent -l 1 --reject="index.html*" -P archives "$LOG_DIR_URL"
curl -f "$SRC_BUILD_URL/timestamps?time=HH:mm:ssZ&appendLog" > archives/console-timestamp.log
if [ -s archives/console-timestamp.log ]; then
    cat archives/console-timestamp.log
else
    cat archives/console.log
fi

#!/bin/bash
# Create a debian package and push to remote repo
#
set -x
echo '================= STARTING SCRIPT TO CREATE DEBIAN FILE ================='
# Extract the username and password to the nexus repo from the settings file
USER=$(xpath -q -e "//servers/server[id='ecomp-raw']/username/text()" "$SETTINGS_FILE")
PASS=$(xpath -q -e "//servers/server[id='ecomp-raw']/password/text()" "$SETTINGS_FILE")
REPO="${NEXUSPROXY}/content/sites/raw"

#Create a netrc file for use with curl
NETRC=$(mktemp)
echo "machine nexus.openecomp.org login $USER password $PASS" > "$NETRC"


#Write an envionment var for the netrc location since it's a temp file
echo "NETRC=$NETRC" > "$WORKSPACE/netrc_env.txt"

STAGE_DIR=${WORKSPACE}/package
OUTPUT_DIR=${WORKSPACE}/package/output

DATE_STAMP="$(date +"%Y%m%d%H%M%S")"
PACKAGE_BUILD_NUMBER=${DATE_STAMP}
PACKAGE_NAME_APPLICATION=$( \
    cat ${WORKSPACE}/dcae-apod-buildtools/configs/package-cdap3vm.json | \
    python -c 'import json,sys;print json.load(sys.stdin)["applicationName"]')
PACKAGE_NAME_VERSION=$( \
    cat ${WORKSPACE}/dcae-apod-buildtools/configs/package-cdap3vm.json | \
    python -c 'import json,sys;print json.load(sys.stdin)["version"]')
PACKAGE_GROUP_ID=$( \
    cat ${WORKSPACE}/dcae-apod-buildtools/configs/package-cdap3vm.json | \
    python -c 'import json,sys;print json.load(sys.stdin)["groupId"]')
OUTPUT_FILE="${PACKAGE_NAME_APPLICATION}_${PACKAGE_NAME_VERSION}.deb"
OUTPUT_FILE_DATE_STAMPED="${PACKAGE_NAME_APPLICATION}_${PACKAGE_NAME_VERSION}-${DATE_STAMP}.deb"

echo 'Package variables:'
echo "    STAGE_DIR = ${STAGE_DIR}"
echo "    OUTPUT_DIR = ${OUTPUT_DIR}"
echo "    PACKAGE_BUILD_NUMBER = ${PACKAGE_BUILD_NUMBER}"
echo "    PACKAGE_NAME_APPLICATION = ${PACKAGE_NAME_APPLICATION}"
echo "    PACKAGE_NAME_VERSION = ${PACKAGE_NAME_VERSION}"
echo "    PACKAGE_GROUP_ID = ${PACKAGE_GROUP_ID}"
echo "    OUTPUT_FILE = ${OUTPUT_FILE}"
echo "    OUTPUT_FILE_DATE_STAMPED = ${OUTPUT_FILE_DATE_STAMPED}"

echo 'Creating Staging and Output directories'
rm -rf ${STAGE_DIR}
rm -rf ${OUTPUT_DIR}
mkdir -p ${STAGE_DIR}/stage/opt/app/dcae-cdap-small-hadoop
mkdir -p ${OUTPUT_DIR}

echo 'Copying files to stage'
cp -R ${WORKSPACE}/cdap3vm/* ${STAGE_DIR}/stage/opt/app/dcae-cdap-small-hadoop

echo 'Copying json file to stage'
cp ${WORKSPACE}/dcae-apod-buildtools/configs/package-cdap3vm.json ${STAGE_DIR}/package.json

echo 'Contents of stage directory'
ls -lR ${STAGE_DIR}

echo "Creating debian package"
${WORKSPACE}/dcae-apod-buildtools/scripts/package -b debian -d ${STAGE_DIR} \
    -o ${OUTPUT_DIR} -y package.json -B ${PACKAGE_BUILD_NUMBER} -v

# The controller needs the debian packaged named
# dcae-cdap-small-hadoop_17.01.0-LATEST.deb so it can find and deploy it.
# In order to have a copy of each file built a copy of
# dcae-cdap-small-hadoop_17.01.0-LATEST.deb will be made and it will have a
# date stamp and build number on it.
# For example:  dcae-cda-small-hadoop_17.01.0-YYYYMMDDHHMMSS-XXX.deb
# Both files will then be uploaded to the repository.
# Verify script does not upload to Nexus

cp ${OUTPUT_DIR}/${OUTPUT_FILE_DATE_STAMPED} ${OUTPUT_DIR}/${OUTPUT_FILE}

echo "Contents of output directory"
ls -lR ${OUTPUT_DIR}

echo '================= ENDING SCRIPT TO CREATE DEBIAN FILE ==================='

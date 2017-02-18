#!/bin/bash
#
# Create a debian package and push to remote repo
#
set -x
echo '================ STARTING SCRIPT TO CREATE DEBIAN FILE =================='

# Extract the username, password for the nexus repo from the maven settings file
USER=$(xpath -q -e "//servers/server[id='ecomp-raw']/username/text()" "$SETTINGS_FILE")
PASS=$(xpath -q -e "//servers/server[id='ecomp-raw']/password/text()" "$SETTINGS_FILE")
OPENECOMP_NEXUS_REPO="${NEXUSPROXY}/content/sites/raw"

#Create a netrc file for use with curl
NETRC=$(mktemp)
echo "machine nexus.dcaeapod.org login $USER password $PASS" > "$NETRC"

#Write an envionment var for the netrc location since it's a temp file
echo "NETRC=$NETRC" > "$WORKSPACE/netrc_env.txt"

STAGE_DIR=${WORKSPACE}/package
OUTPUT_DIR=${WORKSPACE}/package/output

DATE_STAMP="$(date +"%Y%m%d%H%M%S")"
PACKAGE_BUILD_NUMBER=${DATE_STAMP}
PACKAGE_NAME_APPLICATION=$( \
    cat ${WORKSPACE}/dcae-apod-buildtools/configs/package-dcae-analytics-tca.json | \
    python -c 'import json,sys;print json.load(sys.stdin)["applicationName"]')
PACKAGE_NAME_VERSION=$( \
    cat ${WORKSPACE}/dcae-apod-buildtools/configs/package-dcae-analytics-tca.json | \
    python -c 'import json,sys;print json.load(sys.stdin)["version"]')
PACKAGE_GROUP_ID=$( \
    cat ${WORKSPACE}/dcae-apod-buildtools/configs/package-dcae-analytics-tca.json | \
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
mkdir -p ${STAGE_DIR}/stage/opt/app/cdap-apps
mkdir -p ${OUTPUT_DIR}

echo 'Copying jar file to stage'
cp ${WORKSPACE}/dcae-analytics-tca/target/dcae-analytics-tca-${POM_VERSION}.jar ${STAGE_DIR}/stage/opt/app/cdap-apps

echo 'Copying json file to stage'
cp ${WORKSPACE}/dcae-apod-buildtools/configs/package-dcae-analytics-tca.json ${STAGE_DIR}/package.json

echo 'Contents of stage directory'
ls -lR ${STAGE_DIR}

echo 'Creating debian package'
${WORKSPACE}/dcae-apod-buildtools/scripts/package -b debian -d ${STAGE_DIR} \
    -o ${OUTPUT_DIR} -y package.json -B ${PACKAGE_BUILD_NUMBER} -v

# The controller needs the debian packaged named
# dcae-analytics-tca_17.01.0-LATEST.deb so it can find and deploy it.
# In order to have a copy of each file built a copy of
# dcae-analytics-tca_17.01.0-LATEST.deb will be made and it will have a
# date stamp and build number on it.
# For example:  dcae-analytics-tca_17.01.0-YYYYMMDDHHMMSS-XXX.deb
# Both files will then be uploaded to the repository.

cp ${OUTPUT_DIR}/${OUTPUT_FILE_DATE_STAMPED} ${OUTPUT_DIR}/${OUTPUT_FILE}

echo "Contents of output directory"
ls -lR ${OUTPUT_DIR}

SEND_TO="${OPENECOMP_NEXUS_REPO}/org.openecomp.dcae/deb-snapshots/${PACKAGE_GROUP_ID}/${OUTPUT_FILE}"
echo "Sending ${OUTPUT_DIR}/${OUTPUT_FILE} to Nexus Repo: ${SEND_TO}"
curl -vkn --netrc-file "${NETRC}" --upload-file ${OUTPUT_DIR}/${OUTPUT_FILE} ${SEND_TO}

SEND_TO="${OPENECOMP_NEXUS_REPO}/org.openecomp.dcae/deb-snapshots/${PACKAGE_GROUP_ID}/${OUTPUT_FILE_DATE_STAMPED}"

echo "Sending ${OUTPUT_DIR}/${OUTPUT_FILE_DATE_STAMPED} to Nexus Repo: ${SEND_TO}"
curl -vkn --netrc-file "${NETRC}" --upload-file ${OUTPUT_DIR}/${OUTPUT_FILE_DATE_STAMPED} ${SEND_TO}

echo "================== ENDING SCRIPT TO CREATE DEBIAN FILE ==================="

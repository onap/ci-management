#!/bin/bash
# Create a debian package and push to remote repo
#

echo "===================== STARTING SCRIPT TO CREATE DEBIAN FILE ======================="
# Extract the username, password and path to the nexus repo from the maven settings file
USER=$(xpath -q -e "//servers/server[id='ecomp-raw']/username/text()" "$SETTINGS_FILE")
PASS=$(xpath -q -e "//servers/server[id='ecomp-raw']/password/text()" "$SETTINGS_FILE")
OPENECOMP_NEXUS_REPO="${NEXUSPROXY}/content/sites/raw"

#Create a netrc file for use with curl
NETRC=$(mktemp)
echo "machine nexus.openecomp.org login $USER password $PASS" > "$NETRC"


#Write an envionment var for the netrc location since it's a temp file
echo "NETRC=$NETRC" > "$WORKSPACE/netrc_env.txt"

STAGE_DIR=${WORKSPACE}/package
OUTPUT_DIR=${WORKSPACE}/package/output

DATE_STAMP="$(date +"%Y%m%d%H%M%S")"
PACKAGE_BUILD_NUMBER=${DATE_STAMP}
PACKAGE_NAME_APPLICATION=$(cat ${WORKSPACE}/dcae-apod-buildtools/configs/package-cdap3vm.json | python -c 'import json,sys;print json.load(sys.stdin)["applicationName"]')
PACKAGE_NAME_VERSION=$(cat ${WORKSPACE}/dcae-apod-buildtools/configs/package-cdap3vm.json | python -c 'import json,sys;print json.load(sys.stdin)["version"]')
PACKAGE_GROUP_ID=$(cat ${WORKSPACE}/dcae-apod-buildtools/configs/package-cdap3vm.json | python -c 'import json,sys;print json.load(sys.stdin)["groupId"]')
OUTPUT_FILE=${PACKAGE_NAME_APPLICATION}"_"${PACKAGE_NAME_VERSION}".deb"
OUTPUT_FILE_DATE_STAMPED=${PACKAGE_NAME_APPLICATION}"_"${PACKAGE_NAME_VERSION}"-"${DATE_STAMP}".deb"


rm -rf ${STAGE_DIR}
rm -rf ${OUTPUT_DIR}
mkdir -p ${STAGE_DIR}/stage/opt/app/dcae-cdap-small-hadoop
mkdir -p ${OUTPUT_DIR}

echo "Copying files to stage"
cp -R ${WORKSPACE}/cdap3vm/* ${STAGE_DIR}/stage/opt/app/dcae-cdap-small-hadoop

echo "Copying json file to stage"
cp ${WORKSPACE}/dcae-apod-buildtools/configs/package-cdap3vm.json ${STAGE_DIR}/package.json

echo "Creating debian package"
${WORKSPACE}/dcae-apod-buildtools/scripts/package -b debian -d ${STAGE_DIR} -o ${OUTPUT_DIR} -y package.json -B ${PACKAGE_BUILD_NUMBER} -v


# The controller needs the debian packaged named dcae-cdap-small-hadoop_17.01.0-LATEST.deb so it can find and deploy it.
# In order to have a copy of each file built a copy of dcae-cdap-small-hadoop_17.01.0-LATEST.deb will be made
# and it will have a date stamp and build number on it.  For example:  dcae-cda-small-hadoop_17.01.0-YYYYMMDDHHMMSS-XXX.deb
# Both files will then be uploaded to the repository.

cp ${OUTPUT_DIR}/${OUTPUT_FILE_DATE_STAMPED} ${OUTPUT_DIR}/${OUTPUT_FILE}

SEND_TO=${OPENECOMP_NEXUS_REPO}"/org.openecomp.dcae.apod.cdap/deb-snapshots/"${PACKAGE_GROUP_ID}"/"${OUTPUT_FILE}
curl -vkn --netrc-file '${NETRC}' --upload-file ${OUTPUT_DIR}/${OUTPUT_FILE} ${SEND_TO}

SEND_TO=${OPENECOMP_NEXUS_REPO}"/org.openecomp.dcae.apod.cdap/deb-snapshots/"${PACKAGE_GROUP_ID}"/"${OUTPUT_FILE_DATE_STAMPED}
curl -vkn --netrc-file '${NETRC}' --upload-file ${OUTPUT_DIR}/${OUTPUT_FILE_DATE_STAMPED} ${SEND_TO}

echo "===================== ENDING SCRIPT TO CREATE DEBIAN FILE ======================="

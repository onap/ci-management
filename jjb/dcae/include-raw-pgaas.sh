#!/bin/bash
# Create a debian package and push to remote repo
#
echo "============== STARTING SCRIPT TO CREATE DEBIAN FILES ================="

export BUILD_NUMBER="${BUILD_ID}"
export PATH=$PATH:${WORKSPACE}/buildtools/bin

export NEXUS_RAW="${NEXUSPROXY}/content/sites/raw"
USER=$(xpath -q -e \
    "//servers/server[id='ecomp-raw']/username/text()" "$SETTINGS_FILE")
PASS=$(xpath -q -e \
    "//servers/server[id='ecomp-raw']/password/text()" "$SETTINGS_FILE")

# Create a netrc file for use with curl
export NETRC=$(mktemp)
echo "machine nexus.openecomp.org login ${USER} password ${PASS}" > "${NETRC}"

echo $NEXUS_RAW


DISTRIBUTION_STAGE=$(cat ${WORKSPACE}/${PROJECT}-diststage)
if [ "$DISTRIBUTION_STAGE" == "VERIFY" ]; then
    REPO="${NEXUS_RAW}/org.openecomp.dcae.devnull"
elif [ "$DISTRIBUTION_STAGE" == "MERGE" ]; then
    REPO="${NEXUS_RAW}/org.openecomp.dcae.pgaas/deb-snapshots"
elif [ "$DISTRIBUTION_STAGE" == "DAILYRELEASE" ]; then
    REPO="${NEXUS_RAW}/org.openecomp.dcae.pgaas/deb-releases"
else
    REPO="${NEXUS_RAW}/org.openecomp.dcae.devnull"
fi

export REPACKAGEDEBIANUPLOAD="set -x; curl -k --netrc-file '${NETRC}' \
    --upload-file '{0}' '${REPO}/{2}/{1}'"
export REPACKAGEDEBIANUPLOAD2="set -x; curl -k --netrc-file '${NETRC}' \
    --upload-file '{0}' '${REPO}/{2}/{4}-LATEST.deb'"
make debian
echo "================= ENDING SCRIPT TO CREATE DEBIAN FILES ================="

#echo "============= STARTING SCRIPT TO CREATE JAVADOCS FILES ================"
#make upload-javadocs
#echo "============= ENDING SCRIPT TO CREATE JAVADOCS FILES =================="

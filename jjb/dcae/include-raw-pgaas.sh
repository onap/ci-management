#!/bin/bash
# Create a debian package and push to remote repo
#
echo "============== STARTING SCRIPT TO CREATE DEBIAN FILES ================="

export BUILD_NUMBER="${BUILD_ID}"
export PATH=$PATH:${WORKSPACE}/buildtools/bin

#export OPENECOMP_NEXUS_RAW="https://nexus.openecomp.org/content/sites/raw"
export OPENECOMP_NEXUS_RAW="${NEXUSPROXY}/content/sites/raw"
export OPENECOMP_NEXUS_USER=$(xpath -q -e \
    "//servers/server[id='ecomp-raw']/username/text()" "$SETTINGS_FILE")
export OPENECOMP_NEXUS_PASSWORD=$(xpath -q -e \
    "//servers/server[id='ecomp-raw']/password/text()" "$SETTINGS_FILE")

echo $OPENECOMP_NEXUS_RAW
echo $OPENECOMP_NEXUS_USER
echo $OPENECOMP_NEXUS_PASSWORD

export REPACKAGEDEBIANUPLOAD="set -x; curl -k \
    --user ${OPENECOMP_NEXUS_USER}:${OPENECOMP_NEXUS_PASSWORD}' \
    --upload-file '{0}' \
        '${OPENECOMP_NEXUS_RAW}/org.openecomp.dcae/deb-snapshots/{2}/{1}'"
export REPACKAGEDEBIANUPLOAD2="set -x; curl -k \
    --user '${OPENECOMP_NEXUS_USER}:${OPENECOMP_NEXUS_PASSWORD}' \
    --upload-file '{0}' \
        '${OPENECOMP_NEXUS_RAW}/org.openecomp.dcae/deb-snapshots/{2}/{4}-LATEST.deb'"
make debian
echo "================= ENDING SCRIPT TO CREATE DEBIAN FILES ================="

#echo "============= STARTING SCRIPT TO CREATE JAVADOCS FILES ================"
#make upload-javadocs
#echo "============= ENDING SCRIPT TO CREATE JAVADOCS FILES =================="

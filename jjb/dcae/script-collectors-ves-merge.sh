#!/bin/bash
#
#
# 1 fetch DCAE Controller service manager
# 2 build the docker imagei with both service manager and ves collector
# 3 tag and then push to the remote repo
#
#
# !!! make sure the yaml jjb file includes docker-login as a builder
# before calling this script


# downloading DCAE Controller service manager for VES collector
GROUP_ID='org.openecomp.dcae.controller'
ARTIFACT_ID='dcae-controller-service-standardeventcollector-manager'
VERSION='0.1.0-SNAPSHOT'
FORMAT='zip'
SCOPE='runtime'
ARTIFACT_FQID="${GROUP_ID}:${ARTIFACT_ID}:${VERSION}:${FORMAT}:${SCOPE}"
ARTIFACT_FILENAME="${ARTIFACT_ID}-${VERSION}-${SCOPE}.${FORMAT}"
mvn -s "$SETTINGS_FILE" \
   org.apache.maven.plugins:maven-dependency-plugin:2.10:copy \
   -Dartifact="${ARTIFACT_FQID}" -DoutputDirectory=/tmp
DCM_AR="/tmp/${ARTIFACT_FILENAME}"
if [ ! -f "${DCM_AR}" ]
then
    echo "FATAL error cannot locate ${DCM_AR}"
    exit 2
fi

# unarchive the service manager
TARGET="${WORKSPACE}"/target
STAGE="${TARGET}"/stage
DCM_DIR="${STAGE}"/opt/app/manager
[ ! -d "${DCM_DIR}" ] && mkdir -p "${DCM_DIR}"
unzip -qo -d "${DCM_DIR}" "${DCM_AR}"

#
# generate the manager start-up.sh
#
[ -f "${DCM_DIR}/start-manager.sh" ] && exit 0

cat <<EOF > "${DCM_DIR}"/start-manager.sh
#!/bin/bash

MAIN='org.openecomp.dcae.controller.service.standardeventcollector.servers.manager.DcaeControllerServiceStandardeventcollectorManagerServer'
ACTION='start'

WORKDIR='/opt/app/manager'
LOGS="${WORKDIR}/logs"

[ ! -d "$LOGS" ] && mkdir -p "$LOGS"

echo 10.0.4.102 $(hostname).dcae.simpledemo.openecomp.org >> /etc/hosts

exec java -cp ./config:./lib:./lib/*:./bin "${MAIN}" "${ACTION}" \
    > logs/manager.out 2>logs/manager.err
EOF

chmod 775 "${DCM_DIR}"/start-manager.sh


#
# generate docker file
#
cat <<EOF > "${STAGE}"/Dockerfile
FROM ubuntu:14.04

MAINTAINER dcae@lists.openecomp.org

WORKDIR /opt/app/manager

ENV HOME /opt/app/SEC
ENV JAVA_HOME /usr

RUN apt-get update && apt-get install -y \
        bc \
        curl \
        telnet \
        vim \
        netcat \
        openjdk-7-jdk

COPY opt /opt

EXPOSE 9999

CMD [ "/opt/app/manager/start-manager.sh" ]
EOF

#
# build the docker image. tag and then push to the remote repo
#
IMAGE='dcae-controller-common-event'
TAG='1.0.0'
LFQI="${IMAGE}:${TAG}"
BUILD_PATH="${WORKSPACE}/target/stage"

# build a docker image
docker build --rm -t "${LFQI}" "${BUILD_PATH}"


#
# push the image
#
# io registry  DOCKER_REPOSITORIES="nexus3.openecomp.org:10001 \
# release registry                   nexus3.openecomp.org:10002 \
# snapshot registry                   nexus3.openecomp.org:10003"
REPO='nexus3.openecomp.org:10003'

if [ ! -z "$REPO" ]; then
    RFQI="${REPO}/${LFQI}"
    # tag
    docker tag "${LFQI}" "${RFQI}"

    # push to remote repo
    docker push "${RFQI}"
fi
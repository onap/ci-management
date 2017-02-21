#!/bin/bash
#
echo '============== STARTING SCRIPT TO BUILD DOCKER IMAGES ================='


DOCKER_REPOSITORY=nexus3.openecomp.org:10003

for image in policy-os policy-nexus policy-db policy-base policy-drools policy-pe ; do
    echo "Building $image"
    mkdir -p target/$image
    cp $image/* target/$image
    docker build --quiet --tag ${DOCKER_REPOSITORY}/openecomp/policy/$image:1.0.0-SNAPSHOT target/$image
    docker images
done

for image in policy-nexus policy-db policy-drools policy-pe; do
    echo "Pushing $image"
    docker push ${DOCKER_REPOSITORY}/openecomp/policy/$image:1.0.0-SNAPSHOT
done

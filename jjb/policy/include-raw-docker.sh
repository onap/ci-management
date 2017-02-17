#!/bin/bash
#
echo '============== STARTING SCRIPT TO BUILD DOCKER IMAGES ================='

for image in policy-os policy-nexus policy-db policy-base policy-drools policy-pe ; do
    mkdir -p target/$image
    cp $image/* target/$image
    docker build --quiet --tag ${DOCKER_REPOSITORY}/policy/$image target/$image
done

for image in policy-nexus policy-db policy-drools policy-pe; do
    docker push ${DOCKER_REPOSITORY}/policy/$image
done

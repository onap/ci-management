#!/bin/bash

## Will update POM in workspace with release version

if [ ! -e version.properties ]; then
	echo "Missing version.properties"
	exit 1
fi

## will setup variable release_version
source ./version.properties

VERSION=$release_version

## handle POM files with no parent
for file in $(find . -name pom.xml); do
	if [ "$(grep -c '<parent>' $file)" == "0" ]; then
		( 
			cd $(dirname $file)
		${MVN} versions:set versions:commit \
			-DnewVersion=$VERSION \
			-DprocessDependencies=false
		)
	fi
done 

find . -name pom.xml.versionsBackup -delete


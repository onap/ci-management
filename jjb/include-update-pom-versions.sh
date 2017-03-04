#!/bin/bash

## Will update POM in workspace with release version

if [ ! -e version.properties ]; then
    echo "Missing version.properties"
    exit 1
fi

## will setup variable release_version
source ./version.properties

RELEASE_VERSION=$release_version

echo Changing POM version to $RELEASE_VERSION

## handle POM
for file in $(find . -name pom.xml); do
    VERSION=$(xpath -q -e '//project/version/text()' $file)
    PVERSION=$(xpath -q -e '//project/parent/version/text()' $file)
    echo before changes VERSION=$VERSION PVERSION=$PVERSION file=$file
    if [ "$VERSION" != "" ]; then
        awk -v v=$RELEASE_VERSION '
            /<version>/ {
                if (! done) {
                    sub(/<version>.*</,"<version>" v "<",$0)
                    done = 1
                }
            }
            { print $0 }
        ' $file > $file.tmp
        mv $file.tmp $file
    fi
    if [ "$PVERSION" != "" ]; then
        awk -v v=$RELEASE_VERSION '
            /<version>/ {
                if (parent && ! done) {
                    sub(/<version>.*</,"<version>" v "<",$0)
                    done = 1
                }
            }
            /<parent>/ { parent = 1 }
            { print $0 }
        ' $file > $file.tmp
        mv $file.tmp $file
    fi
    VERSION=$(xpath -q -e '//project/version/text()' $file)
    PVERSION=$(xpath -q -e '//project/parent/version/text()' $file)
    echo after changes VERSION=$VERSION PVERSION=$PVERSION file=$file
done


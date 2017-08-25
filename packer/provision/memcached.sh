#!/bin/bash
# This particular environment was created specifically for MultiCloud

# vim: ts=4 sw=4 sts=4 et tw=72 :

# force any errors to cause the script and job to end in failure
set -xeu -o pipefail

rh_systems() {
    # memcached
    yum install -y memcached
    systemctl enable memcached
}

ubuntu_systems() {
    # memcached
    apt-get install memcached
}

all_systems() {
    echo 'No common distribution configuration to perform'
}

echo "---> Detecting OS"
ORIGIN=$(facter operatingsystem | tr '[:upper:]' '[:lower:]')

case "${ORIGIN}" in
    fedora|centos|redhat)
        echo "---> RH type system detected"
        rh_systems
    ;;
    ubuntu)
        echo "---> Ubuntu system detected"
        ubuntu_systems
    ;;
    *)
        echo "---> Unknown operating system"
    ;;
esac

# execute steps for all systems
all_systems

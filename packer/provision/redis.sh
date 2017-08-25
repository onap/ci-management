#!/bin/bash
# This particular environment was created specifically for vfc-nfvo-lcm

# vim: ts=4 sw=4 sts=4 et tw=72 :

# force any errors to cause the script and job to end in failure
set -xeu -o pipefail

rh_systems() {
    # redis
    yum install -y redis
    systemctl enable redis.service
}

ubuntu_systems() {
    # redis

    # 1. download and install redis
    cd /tmp
    wget http://download.redis.io/releases/redis-4.0.1.tar.gz
    tar -zxf redis-4.0.1.tar.gz
    cd /tmp/redis-4.0.1
    make
    make install

    # 2. set conf file and init script
    cp /tmp/redis-4.0.1/src/redis-server /etc/init.d/redis-server
    chmod +x /etc/init.d/redis-server
    cp /tmp/redis-4.0.1/redis.conf /etc/redis.conf

    # 3. set auto start when start system
    redis-server /etc/redis.conf &
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

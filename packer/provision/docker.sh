#!/bin/bash

# vim: ts=4 sw=4 sts=4 et tw=72 :

# force any errors to cause the script and job to end in failure
set -xeu -o pipefail

rh_systems() {
    # Assumes that python is already installed by basebuild

    # Install dependencies for robotframework and robotframework-sshlibrary
    yum install -y yum-utils unzip sshuttle nc libffi-devel openssl-devel

    # Install docker
    yum install -y docker supervisor bridge-utils
    systemctl enable docker

    # configure docker networking so that it does not conflict with LF
    # internal networks
    cat <<EOL > /etc/sysconfig/docker-network
# /etc/sysconfig/docker-network
DOCKER_NETWORK_OPTIONS='--bip=10.250.0.254/24'
EOL
    # configure docker daemon to listen on port 5555 enabling remote
    # managment
    sed -i -e "s#='--selinux-enabled'#='--selinux-enabled -H unix:///var/run/docker.sock -H tcp://0.0.0.0:5555'#g" /etc/sysconfig/docker

    # docker group doesn't get created by default for some reason
    groupadd docker
}

ubuntu_systems() {
    # Assumes that python is already installed by basebuild

    # Install Python3.6
    sudo add-apt-repository -y ppa:jonathonf/python-3.6
    sudo apt-get update
    sudo apt-get install -y python3.6

    # Install dependencies for robotframework and robotframework-sshlibrary
    apt install -y unzip sshuttle netcat libffi-dev libssl-dev
    wget https://github.com/mozilla/geckodriver/releases/download/v0.18.0/geckodriver-v0.18.0-linux64.tar.gz
    tar xvzf geckodriver-v0.18.0-linux64.tar.gz -C /usr/local/bin
    export PATH=$PATH:/usr/local/bin

    # Install docker
    apt install -y docker.io
}

all_systems() {
    # Install docker-compose
    curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.15.0/docker-compose-$(uname -s)-$(uname -m)"
    chmod +x /usr/local/bin/docker-compose
    docker-compose -v
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

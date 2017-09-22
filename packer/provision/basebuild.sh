#!/bin/bash

# vim: ts=4 sw=4 sts=4 et tw=72 :

# force any errors to cause the script and job to end in failure
set -xeu -o pipefail

rh_systems() {
    # Install python dependencies
    yum install -y python-{devel,virtualenv,setuptools,pip}

    # Build dependencies for Python packages
    yum install -y openssl-devel mysql-devel gcc

    # Autorelease support packages
    yum install -y firefox python-tox xmlstarlet xvfb

    # Install chrome to support ChromeDriver
    cat <<EOF > /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome
baseurl=http://dl.google.com/linux/chrome/rpm/stable/$basearch
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOF

    yum -y update
    yum -y install google-chrome-stable

    # Additional libraries for Python ncclient
    yum install -y libxml2 libxslt libxslt-devel libffi libffi-devel

    # Packer builds happen from the centos flavor images
    PACKERDIR=$(mktemp -d)
    # disable double quote checking
    # shellcheck disable=SC2086
    cd $PACKERDIR
    wget https://releases.hashicorp.com/packer/0.12.2/packer_0.12.2_linux_amd64.zip
    unzip packer_0.12.2_linux_amd64.zip -d /usr/local/bin/
    # rename packer to avoid conflicts with cracklib
    mv /usr/local/bin/packer /usr/local/bin/packer.io

    # cleanup from the installation
    # disable double quote checking
    # shellcheck disable=SC2086
    rm -rf $PACKERDIR
    # cleanup from previous install process
    if [ -d /tmp/packer ]
    then
        rm -rf /tmp/packer
    fi
}

ubuntu_systems() {
    # Install python dependencies
    apt-get install -y python-{dev,virtualenv,setuptools,pip}

    # Build dependencies for Python packages
    apt-get install -y libssl-dev libmysqlclient-dev gcc

    # Autorelease support packages
    apt-get install -y firefox python-tox xmlstarlet xvfb

    # Install chrome to support ChromeDriver
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
    apt-get update -y
    apt-get install -y google-chrome-stable

    # Additional libraries for Python ncclient
    apt-get install -y wget unzip python-ncclient

    # Add graphviz for documentation building
    apt-get install -y graphviz

    # Erlang and Rebar packages needed for DCAEGEN2
    apt-get install -y libwxgtk3.0-0v5 libsctp1
    wget https://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_19.3.6-1~ubuntu~trusty_amd64.deb
    dpkg -i esl-erlang_19.3.6-1~ubuntu~trusty_amd64.deb
    apt-get install -y libwxbase3.0-0v5
    apt-get -f install -y
    git clone https://github.com/erlang/rebar3.git
    cd rebar3
    ./bootstrap
    mv rebar3 /usr/bin/rebar3
    cd ..
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

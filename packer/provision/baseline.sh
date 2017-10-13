#!/bin/bash

# vim: ts=4 sw=4 sts=4 et tw=72 :

# force any errors to cause the script and job to end in failure
set -xeu -o pipefail

rh_systems() {
    # Handle the occurance where SELINUX is actually disabled
    SELINUX=$(grep -E '^SELINUX=(disabled|permissive|enforcing)$' /etc/selinux/config)
    MODE=$(echo "$SELINUX" | cut -f 2 -d '=')
    case "$MODE" in
        permissive)
            echo "************************************"
            echo "** SYSTEM ENTERING ENFORCING MODE **"
            echo "************************************"
            # make sure that the filesystem is properly labelled.
            # it could be not fully labeled correctly if it was just switched
            # from disabled, the autorelabel misses some things
            # skip relabelling on /dev as it will generally throw errors
            restorecon -R -e /dev /

            # enable enforcing mode from the very start
            setenforce enforcing

            # configure system for enforcing mode on next boot
            sed -i 's/SELINUX=permissive/SELINUX=enforcing/' /etc/selinux/config
        ;;
        disabled)
            sed -i 's/SELINUX=disabled/SELINUX=permissive/' /etc/selinux/config
            touch /.autorelabel

            echo "*******************************************"
            echo "** SYSTEM REQUIRES A RESTART FOR SELINUX **"
            echo "*******************************************"
        ;;
        enforcing)
            echo "*********************************"
            echo "** SYSTEM IS IN ENFORCING MODE **"
            echo "*********************************"
        ;;
    esac

    echo "---> Updating operating system"
    yum clean all
    yum install -y deltarpm
    yum update -y

    # add in components we need or want on systems
    echo "---> Installing base packages"
    yum install -y @base https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    # separate group installs from package installs since a non-existing
    # group with dnf based systems (F21+) will fail the install if such
    # a group does not exist
    yum install -y unzip xz puppet git git-review perl-XML-XPath wget make

    # All of our systems require Java (because of Jenkins)
    # Install all versions of the OpenJDK devel but force 1.7.0 to be the
    # default

    echo "---> Configuring OpenJDK"
    yum install -y 'java-*-openjdk-devel'

    FACTER_OS=$(/usr/bin/facter operatingsystem)
    FACTER_OSVER=$(/usr/bin/facter operatingsystemrelease)
    case "$FACTER_OS" in
        Fedora)
            if [ "$FACTER_OSVER" -ge "21" ]
            then
                echo "---> not modifying java alternatives as OpenJDK 1.7.0 does not exist"
            else
                alternatives --set java /usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java
                alternatives --set java_sdk_openjdk /usr/lib/jvm/java-1.7.0-openjdk.x86_64
            fi
        ;;
        RedHat|CentOS)
            if [ "$(echo $FACTER_OSVER | cut -d'.' -f1)" -ge "7" ]
            then
                echo "---> not modifying java alternatives as OpenJDK 1.7.0 does not exist"
            else
                alternatives --set java /usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java
                alternatives --set java_sdk_openjdk /usr/lib/jvm/java-1.7.0-openjdk.x86_64
            fi
        ;;
        *)
            alternatives --set java /usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java
            alternatives --set java_sdk_openjdk /usr/lib/jvm/java-1.7.0-openjdk.x86_64
        ;;
    esac

    # Needed to parse OpenStack commands used by infra stack commands
    # to initialize Heat template based systems.
    yum install -y jq
}

ubuntu_systems() {
    # Ignore SELinux since slamming that onto Ubuntu leads to
    # frustration

    export DEBIAN_FRONTEND=noninteractive
    cat <<EOF >> /etc/apt/apt.conf
APT {
  Get {
    Assume-Yes "true";
    allow-change-held-packages "true";
    allow-downgrades "true";
    allow-remove-essential "true";
  };
};

Dpkg::Options {
  "--force-confdef";
  "--force-confold";
};

EOF

    echo "---> Updating operating system"
    apt-get update
    apt-get upgrade

    # add in stuff we know we need
    echo "---> Installing base packages"
    apt-get install unzip xz-utils puppet git git-review libxml-xpath-perl make wget

    # install Java 7
    echo "---> Configuring OpenJDK"
    FACTER_OSVER=$(/usr/bin/facter operatingsystemrelease)
    case "$FACTER_OSVER" in
        14.04)
            apt-get install openjdk-7-jdk
            # make jdk8 available
            add-apt-repository -y ppa:openjdk-r/ppa
            apt-get update
            # We need to force openjdk-8-jdk to install
            apt-get install openjdk-8-jdk
            # make sure that we still default to openjdk 7
            update-alternatives --set java /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java
            update-alternatives --set javac /usr/lib/jvm/java-7-openjdk-amd64/bin/javac

            # disable auto-update service?
            if [ -f /etc/cron.daily/apt ]
            then
                rm -rf /etc/cron.daily/apt
            fi
        ;;
        16.04)
            apt-get install openjdk-8-jdk
            export JAVA_HOME='/usr/lib/jvm/java-8-openjdk-amd64/jre'

            # force auto-update services off and mask them so they can't
            # be started
            for i in apt-daily.{service,timer}
            do
                systemctl disable ${i}
                systemctl mask ${i}
            done
        ;;
        *)
            echo "---> Unknown Ubuntu version $FACTER_OSVER"
            exit 1
        ;;
    esac



    # Needed to parse OpenStack commands used by infra stack commands
    # to initialize Heat template based systems.
    apt-get install jq

    # disable unattended upgrades & daily updates
    echo '---> Disabling automatic daily upgrades'
    grep -lR 'APT::Periodic' /etc/apt/apt.conf.d/ | perl -pi -e 's/"1"/"0"/g'

}

all_systems() {
    # Allow jenkins access to update-alternatives command to switch java version
    cat <<EOF >/etc/sudoers.d/89-jenkins-user-defaults
Defaults:jenkins !requiretty
jenkins ALL = NOPASSWD: /usr/bin/update-alternatives
EOF

    # Do any Distro specific installations here
    echo "Checking distribution"
    FACTER_OS=$(/usr/bin/facter operatingsystem)
    case "$FACTER_OS" in
        *)
            echo "---> $FACTER_OS found"
            echo "No extra steps for $FACTER_OS"
        ;;
    esac
}

echo "---> Attempting to detect OS"
# upstream cloud images use the distro name as the initial user
ORIGIN=$(if [ -e /etc/redhat-release ]
    then
        echo redhat
    else
        echo ubuntu
    fi)
#ORIGIN=$(logname)

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

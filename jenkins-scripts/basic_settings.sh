#!/bin/bash
# @License EPL-1.0 <http://spdx.org/licenses/EPL-1.0>
##############################################################################
# Copyright (c) 2016 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################

case "$(facter operatingsystem)" in
  Ubuntu)
    apt-get update
    ;;
  *)
    # Do nothing on other distros for now
    ;;
esac

IPADDR=$(facter ipaddress)
HOSTNAME=$(facter hostname)
FQDN=$(facter fqdn)

echo "${IPADDR} ${HOSTNAME} ${FQDN}" >> /etc/hosts

#Increase limits
cat <<EOF > /etc/security/limits.d/jenkins.conf
jenkins         soft    nofile          16000
jenkins         hard    nofile          16000
EOF

cat <<EOSSH >> /etc/ssh/ssh_config
Host *
  ServerAliveInterval 60

# we don't want to do SSH host key checking on spin-up systems
Host 10.30.104.*
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOSSH

cat <<EOKNOWN >  /etc/ssh/ssh_known_hosts
[gerrit.openecomp.org]:29418 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyAKv0UzEhpGKP/rW+yHpngl32Ppr5Uy42coz/sYZYxbtpI+9yaMqfoBb06ktmt6kV7OCT/Sc0OpyWmpcR0d7KZHxx/LE/nm7Gi+xkNHhb9G+Hn6DagP4V+LS6x1YlUt2InLCb8g07+/n6rfxqCI6emIJYu9aTpDhaARb+mMX1xzJuoa4wp59Yr1mkKK8lXHKGnPCemyl9a0vSRY58b7ZWG/N8giNvqYeptslIF1E/MEI5AP6nx7EupiVulAUdboAnDSD0urt9zdE8KRjboghB7PHguil6/OZhbqOb/uEt/rGCHn+02pig1K/vjFvCqNErNgS6EKj0IkH+cU/vjV6j
EOKNOWN

# vim: sw=2 ts=2 sts=2 et :

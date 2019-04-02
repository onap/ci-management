#!/bin/bash
# SPDX-License-Identifier: EPL-1.0
##############################################################################
# Copyright (c) 2019 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################
echo "---> nexus3_port_forwarding.sh"
set +e  # DON'T fail build if script fails.

NEXUS3_IP=`host nexus3.onap.org | awk '/has address/ { print $4 ; exit }'`
OS_ARCH=$(ANSIBLE_STDOUT_CALLBACK=json ANSIBLE_LOAD_CALLBACK_PLUGINS=1 \
    ansible all -i "localhost," --connection=local -m setup | jq -r \
    '.. | .ansible_architecture? | select(type != "null")' \
    | tr '[:upper:]' '[:lower:]')


if [[ "${OS_ARCH}" == "aarch64" ]] ;then
  echo "os_arch: $OS_ARCH"
  iptables -t nat -I OUTPUT 1 -p tcp -d ${NEXUS3_IP} --dport 10001 -j DNAT --to-destination ${NEXUS3_IP}:11001
  iptables -t nat -I OUTPUT 1 -p tcp -d ${NEXUS3_IP} --dport 10002 -j DNAT --to-destination ${NEXUS3_IP}:11002
  iptables -t nat -I OUTPUT 1 -p tcp -d ${NEXUS3_IP} --dport 10003 -j DNAT --to-destination ${NEXUS3_IP}:11003
fi

# DON'T fail build if script fails.
exit 0

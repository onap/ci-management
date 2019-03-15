#!/bin/bash

# setting-up bash flags
set -x -e -o pipefail

# remove old ansible - current centos build minion
# is quite old and using incompatible ansible 2.4.x
sudo yum -y remove ansible
sudo pip install ansible ansible-lint

# perform check
ansible --version
ansible-lint --version
ansible-lint ./ansible/site.yml -vvv

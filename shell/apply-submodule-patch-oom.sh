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

# Update kubernetes submodule under oom with patch to be verified

echo '--> apply-submodule-patch-oom.sh'
cd kubernetes/${HELM_MODULE}
remote_path=`git remote -v | grep fetch | awk '{print $2}'`
git fetch ${remote_path} $GERRIT_REFSPEC && git cherry-pick FETCH_HEAD
cd ../..

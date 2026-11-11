#!/usr/bin/env bash
# Copyright (C) 2026 Deutsche Telekom AG. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail
ui_dir=so-admin-cockpit-monitoring-workflow/so-admin-cockpit-monitoring-workflow-ui
image="cockpit-frontend-${BUILD_NUMBER}-${EXECUTOR_NUMBER}"
container="cockpit-frontend-${BUILD_TAG}"
cleanup() {
    docker rm -f "$container" >/dev/null 2>&1 || true
    docker image rm "$image" >/dev/null 2>&1 || true
}
trap cleanup EXIT
trap 'exit 130' INT TERM
docker build -t "$image" "$ui_dir/ci"
docker run --name "$container" --init --ipc=host \
    --user "$(id -u):$(id -g)" \
    -e HOME=/tmp -e CI=true \
    -v "$WORKSPACE:$WORKSPACE" -w "$WORKSPACE" \
    -v "$GLOBAL_SETTINGS_FILE:/tmp/cockpit-global-settings.xml:ro" \
    -v "$SETTINGS_FILE:/tmp/cockpit-settings.xml:ro" \
    "$image" bash "$ui_dir/ci/verify-container.sh"

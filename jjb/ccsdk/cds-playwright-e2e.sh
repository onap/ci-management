#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
##############################################################################
# Run Playwright end-to-end tests for the CDS UI.
#
# Playwright starts three services automatically (mock-processor, LoopBack
# BFF, Angular dev-server) and runs headless Firefox tests against them.
# See cds-ui/e2e-playwright/README.md for details.
##############################################################################
set -e -o pipefail

echo "---> cds-playwright-e2e.sh"

# ── Install Node.js 18 LTS ────────────────────────────────────────────────────
echo "---> Installing Node.js 18"
sudo apt-get update -qq
sudo apt-get install -y -qq nodejs npm > /dev/null 2>&1
sudo npm install -g n > /dev/null 2>&1
sudo n 18 > /dev/null 2>&1
hash -r
echo "Node.js version: $(node --version)"
echo "npm version:     $(npm --version)"

# ── Install dependencies for each component ───────────────────────────────────

echo "---> Installing server (LoopBack BFF) dependencies"
cd "$WORKSPACE/cds-ui/server"
npm install

echo "---> Installing designer-client (Angular) dependencies"
cd "$WORKSPACE/cds-ui/designer-client"
npm install

echo "---> Installing e2e-playwright dependencies"
cd "$WORKSPACE/cds-ui/e2e-playwright"
npm install

# ── Install Playwright browser (Firefox, matching the config) ──────────────────
echo "---> Installing Playwright Firefox browser with system dependencies"
npx playwright install --with-deps firefox

# ── Run the tests ──────────────────────────────────────────────────────────────
echo "---> Running Playwright e2e tests (CI=true)"
export CI=true
npm test

echo "---> Playwright e2e tests completed"

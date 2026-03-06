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

# ── Install Node.js via nvm (no sudo/apt) ───────────────────────────────────
NODE_VERSION="${NODE_VERSION:-18}"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
export NVM_DIR

echo "---> Preparing Node.js ${NODE_VERSION} with nvm"

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
	echo "---> Installing nvm"
	curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# shellcheck source=/dev/null disable=SC1090
source "$NVM_DIR/nvm.sh"

nvm install "$NODE_VERSION"
nvm use "$NODE_VERSION"

echo "Node.js version: $(node --version)"
echo "npm version:     $(npm --version)"

npm_install() {
	if [[ -f package-lock.json ]]; then
		npm ci
	else
		npm install
	fi
}

# ── Install dependencies for each component ───────────────────────────────────

echo "---> Installing server (LoopBack BFF) dependencies"
cd "$WORKSPACE/cds-ui/server"
npm_install

echo "---> Installing designer-client (Angular) dependencies"
cd "$WORKSPACE/cds-ui/designer-client"
npm_install

echo "---> Installing e2e-playwright dependencies"
cd "$WORKSPACE/cds-ui/e2e-playwright"
npm_install

# ── Install Playwright browser (Firefox, matching the config) ────────────────
echo "---> Installing Playwright Firefox browser"
npx playwright install firefox

# ── Run the tests ──────────────────────────────────────────────────────────────
echo "---> Running Playwright e2e tests (CI=true)"
export CI=true
npm test

echo "---> Playwright e2e tests completed"

#!/bin/bash -l
# SPDX-License-Identifier: EPL-1.0
##############################################################################
# Copyright (c) 2024 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################
# shellcheck disable=SC2153,SC2034
echo "---> Deploy Helm charts on K8S cluster and verify deployment"
set -eux -o pipefail

set -x

# shellcheck disable=SC1090
. ~/lf-env.sh

K8S_DEPLOY_LOG="$WORKSPACE/archives/k8s-kubectl-file.log"
mkdir -p "$WORKSPACE/archives"

KUBECONFIG="${WORKSPACE}/config"
export KUBECONFIG

chmod 600 $KUBECONFIG
sudo ln -s /usr/local/bin/helm3.8 /usr/local/bin/helm

#mkdir .kube
#cp ${KUBECONFIG} .kube/config

kubectl create namespace onap
kubectl label namespace onap istio-injection=enabled --overwrite

helm repo add jetstack https://charts.jetstack.io --force-update
helm repo update
kubectl create namespace cert-manager
helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --version v1.14.5 --set installCRDs=true --set prometheus.enabled=false

KEYCLOAK_DATABASE=keycloak-db-values.yaml
KEYCLOAK_SERVER=keycloak-server-values.yaml

helm repo add bitnami https://charts.bitnami.com/bitnami --force-update
helm repo add codecentric https://codecentric.github.io/helm-charts --force-update
helm repo update
kubectl create namespace keycloak
kubectl label namespace keycloak istio-injection=enabled
helm -n keycloak upgrade -i keycloak-db bitnami/postgresql --values ${KEYCLOAK_DATABASE}
helm -n keycloak upgrade -i keycloak codecentric/keycloak --values ${KEYCLOAK_SERVER}

ISTIOD_YAML=istiod.yaml
ENVOYFILTER=envoyfilter-case.yaml
COMMON_GATEWAY=common-gateway.yaml

helm repo add istio https://istio-release.storage.googleapis.com/charts --force-update
helm repo update
kubectl create namespace istio-config
kubectl create namespace istio-system
helm upgrade -i istio-base istio/base -n istio-system --version 1.19.3
helm upgrade -i istiod istio/istiod -n istio-system --version 1.19.3 --wait -f ${ISTIOD_YAML}
kubectl apply -f ${ENVOYFILTER}
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/experimental-install.yaml
kubectl create namespace istio-ingress
kubectl apply -f ${COMMON_GATEWAY}

kubectl create ns strimzi-system
helm repo add strimzi https://strimzi.io/charts/ --force-update
helm repo update
helm --namespace=strimzi-system --version=0.40.0 upgrade -i --reset-values strimzi-kafka-operator strimzi/strimzi-kafka-operator --set watchAnyNamespace=true

CASSANDRA=cassandra.yaml

helm repo add k8ssandra https://helm.k8ssandra.io/stable --force-update
helm repo update
kubectl create namespace k8ssandra-operator
kubectl label namespace k8ssandra-operator istio-injection=enabled
helm upgrade -i k8ssandra-operator k8ssandra/k8ssandra-operator --namespace=k8ssandra-operator --version=1.13.0 --values ${CASSANDRA}

MARIADB=mariadb.yaml

helm repo add mariadb-operator https://mariadb-operator.github.io/mariadb-operator --force-update
helm repo update
kubectl create namespace mariadb-operator
kubectl label namespace mariadb-operator istio-injection=enabled
helm upgrade -i mariadb-operator mariadb-operator/mariadb-operator --namespace=mariadb-operator --version=0.25.0 --values ${MARIADB}

CHARTMUSEUM_URL=https://get.helm.sh/chartmuseum-v0.16.1-linux-amd64.tar.gz
OOM_BRANCH=master
OVERRIDE=override.yaml
GERRIT_REVIEW=137736
GERRIT_MAGIC_NUMBER=36
GERRIT_PATCHSET=23

curl -v -o "chartmuseum.tar.gz" "${CHARTMUSEUM_URL}"
tar -xf chartmuseum.tar.gz
./linux-amd64/chartmuseum --port=8080 --storage='local' --allow-overwrite --storage-local-rootdir="~/charts" &
git clone -b "${OOM_BRANCH}" "https://gerrit.onap.org/r/oom"

if [[ -n "$GERRIT_REVIEW" ]]; then
  GERRIT_MAGIC_NUMBER="${GERRIT_REVIEW: -2}"
  cd oom
  git fetch https://gerrit.onap.org/r/oom "refs/changes/${GERRIT_MAGIC_NUMBER}/${GERRIT_REVIEW}/${GERRIT_PATCHSET}"
  git reset --hard FETCH_HEAD
  cd ..
fi

if [ "$OOM_BRANCH" == "montreal" ]; then
  CHART_VERSION="13.0.0"
else
  CHART_VERSION="14.0.0"
fi

helm repo add --force-update "local" "http://127.0.0.1:8080"
helm repo add --force-update "onap" "http://127.0.0.1:8080"
helm plugin install --version v0.10.4 https://github.com/chartmuseum/helm-push.git
helm plugin install oom/kubernetes/helm/plugins/deploy
helm plugin install oom/kubernetes/helm/plugins/undeploy
helm repo update
cd oom/kubernetes
make SKIP_LINT=TRUE all
make SKIP_LINT=TRUE onap
helm repo update
helm deploy onap local/onap --verbose --namespace onap --set global.masterPassword=gating --version ${CHART_VERSION} -f onap/resources/environments/core-onap.yaml -f onap/resources/overrides/onap-all-ingress-gatewayapi.yaml -f ../../${OVERRIDE} --timeout 900s --delay

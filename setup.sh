#!/usr/bin/env bash
set -euo pipefail
THIS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Install helm if missing
if ! command -v helm &>/dev/null; then
  echo "Installing Helm..."
  TMP=$(mktemp -d)
  curl -sSL https://get.helm.sh/helm-$(curl -sSL https://api.github.com/repos/helm/helm/releases/latest | grep -Po '"tag_name":\s*"v\K[0-9.]+')-$(uname | tr '[:upper:]' '[:lower:]')-amd64.tar.gz -o $TMP/helm.tgz
  tar -C $TMP -xzf $TMP/helm.tgz
  sudo mv $TMP/*/helm /usr/local/bin/
fi

# microk8s kubeconfig
if [[ "$(kubectl config current-context 2>/dev/null)" == "microk8s" ]]; then
  export KUBECONFIG=/var/snap/microk8s/current/credentials/client.config
fi

cd "$THIS_DIR/terraform"
terraform init -input=false
terraform apply -auto-approve -input=false -var="kubeconfig_path=${KUBECONFIG:-$HOME/.kube/config}"
terraform output argocd_admin_password


#!/usr/bin/env bash
set -euo pipefail

# Setup for microk8s
if [[ "$(kubectl config current-context 2>/dev/null)" == "microk8s" ]]; then
  export KUBECONFIG=/var/snap/microk8s/current/credentials/client.config
fi

cd "$(dirname "$0")/terraform"

# Apply ArgoCD CRDs manually
echo "Applying Argo CD CRDs..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/crds.yaml

# Init Terraform
terraform init
terraform apply -auto-approve -var="kubeconfig_path=${KUBECONFIG:-$HOME/.kube/config}"
terraform output argocd_admin_password

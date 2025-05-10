#!/usr/bin/env bash
# Single-command bootstrap for the DevEnv GitOps platform
set -euo pipefail

# ---- Requirements --------------------------------------------------------
# ---- Requirements --------------------------------------------------------
NEEDED=(kubectl helm terraform)
if [[ -z "${SKIP_KIND:-}" ]]; then
  NEEDED+=(kind)
fi

for bin in "${NEEDED[@]}"; do
  if ! command -v "$bin" &>/dev/null; then
    echo "❌ Required binary '$bin' is not installed or not in PATH." >&2
    exit 1
  fi
done


# ---- Create / reuse kind cluster ----------------------------------------
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "⏳ Creating kind cluster '${CLUSTER_NAME}' …"
  kind create cluster --name "${CLUSTER_NAME}" --wait 60s
else
  echo "✅ Using existing kind cluster '${CLUSTER_NAME}'"
fi

# ---- Terraform bootstrap -------------------------------------------------
echo "🚀 Bootstrapping GitOps stack with Terraform …"
terraform -chdir="$DIR/terraform" init -upgrade
terraform -chdir="$DIR/terraform" apply -auto-approve -var=kubeconfig="$KUBECONFIG"

echo
echo "🎉 Dev environment is ready!"
echo "➡️  Argo CD UI:   kubectl -n argocd port-forward svc/argocd-server 8080:443"
echo "➡️  Grafana UI:   kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80"
echo
echo "Login password (first time):"
echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo"

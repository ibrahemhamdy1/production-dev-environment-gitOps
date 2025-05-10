#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# One-shot installer for Whitehelment dev environment
# Requirements:
#   • kubectl
#   • helm v3.x
#   • a working KUBECONFIG context that points at your cluster
# -----------------------------------------------------------------------------
set -euo pipefail

# ---- 0. Prerequisites -------------------------------------------------------
command -v kubectl >/dev/null || { echo "kubectl not found"; exit 1; }
command -v helm    >/dev/null || { echo "helm not found"; exit 1; }

echo "🔍 Using Kubernetes context: $(kubectl config current-context)"
read -rp "Proceed? [y/N] " ans
[[ $ans == [yY] ]] || { echo "Aborted."; exit 0; }

# ---- 1. Namespaces ----------------------------------------------------------
echo "🛠️  Creating core namespaces…"
kubectl apply -f k8s/base/01-namespaces.yaml

# ---- 2. Install Argo CD via Helm -------------------------------------------
echo "🚀 Installing Argo CD (Helm)…"
helm upgrade --install argocd argo-cd \
  --repo https://argoproj.github.io/argo-helm \
  --namespace argocd \
  --version 6.7.3 \
  -f terraform/values/argocd-values.yaml

echo "⏳ Waiting for Argo CD server deployment to roll out…"
kubectl -n argocd rollout status deploy/argocd-server --timeout=5m

# ---- 3. Bootstrap “App of Apps” --------------------------------------------
echo "🧩 Bootstrapping App-of-Apps…"
kubectl apply -f k8s/argocd/app-of-apps.yaml

# ---- 4. Wait for child apps to sync ----------------------------------------
echo "⏳ Waiting for Ingress-NGINX & Prometheus stack to sync…"
until kubectl -n argocd get app ingress-nginx kube-prometheus-stack >/dev/null 2>&1; do
  sleep 2
done
kubectl -n argocd wait --for=condition=Synced app/ingress-nginx app/kube-prometheus-stack --timeout=5m

# ---- 5. Output credentials & helpful commands ------------------------------
echo
echo "✅ All done!"
ARGO_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
          -o jsonpath='{.data.password}' | base64 -d)
cat <<EOF

Argo CD UI
----------------------------------------------------------------------------
kubectl -n argocd port-forward svc/argocd-server 8080:443 &
Open: https://localhost:8080
User:  admin
Pass:  $ARGO_PWD

Grafana UI
----------------------------------------------------------------------------
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80 &
Open: http://localhost:3000
User:  admin      Pass: prom-operator

Happy GitOps-ing! ✨
EOF

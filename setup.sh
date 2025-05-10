#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# One-shot installer for Whitehelment dev environment
# Installs Helm automatically if missing.
# -----------------------------------------------------------------------------
set -euo pipefail

# ------------ 0. Ensure kubectl is available ---------------------------------
command -v kubectl >/dev/null || {
  echo "kubectl not found; install kubectl first." >&2
  exit 1
}

# ------------ 1. Ensure Helm (auto-install if needed) ------------------------
if ! command -v helm >/dev/null; then
  echo "🛠  Helm not found. Installing Helm 3…"
  HELM_VERSION=$(curl -sSL https://api.github.com/repos/helm/helm/releases/latest \
                   | grep -Po '"tag_name":\s*"\Kv[0-9.]+' | head -1)

  case "$(uname -s)" in
    Linux*)   OS=linux  ;;
    Darwin*)  OS=darwin ;;
    *)        echo "Unsupported OS for auto-install"; exit 1 ;;
  esac

  TMP_DIR=$(mktemp -d)
  curl -sSL -o "$TMP_DIR/helm.tgz" \
      "https://get.helm.sh/helm-${HELM_VERSION}-${OS}-amd64.tar.gz"
  tar -C "$TMP_DIR" -xzf "$TMP_DIR/helm.tgz"

  echo "→ Copying helm to /usr/local/bin (sudo)…"
  sudo mv "$TMP_DIR/${OS}-amd64/helm" /usr/local/bin/helm
  sudo chmod +x /usr/local/bin/helm
  rm -rf "$TMP_DIR"
  echo "✅ Helm $(helm version --short) installed."
fi

# ------------ 2. Show current context & confirm ------------------------------
echo "🔍 Using Kubernetes context: $(kubectl config current-context)"
read -rp "Proceed with install? [y/N] " ans
[[ $ans == [yY] ]] || { echo "Aborted."; exit 0; }

# ------------ 3. Create namespaces ------------------------------------------
echo "🛠  Creating core namespaces…"
kubectl apply -f k8s/base/01-namespaces.yaml

# ------------ 4. Install Argo CD via Helm ------------------------------------
echo "🚀 Installing Argo CD (Helm)…"
helm upgrade --install argocd argo-cd \
  --repo https://argoproj.github.io/argo-helm \
  --namespace argocd \
  --version 6.7.3 \
  -f terraform/values/argocd-values.yaml

echo "⏳ Waiting for Argo CD server deployment…"
kubectl -n argocd rollout status deploy/argocd-server --timeout=5m

# ------------ 5. Bootstrap “App of Apps” ------------------------------------
echo "🧩 Bootstrapping App-of-Apps…"
kubectl apply -f k8s/argocd/app-of-apps.yaml

# ------------ 6. Wait for child apps to sync ---------------------------------
echo "⏳ Waiting for child applications to sync (Ingress & Prometheus)…"
until kubectl -n argocd get app ingress-nginx kube-prometheus-stack >/dev/null 2>&1; do
  sleep 2
done
kubectl -n argocd wait \
  --for=condition=Synced app/ingress-nginx app/kube-prometheus-stack \
  --timeout=5m

# ------------ 7. Output credentials & helper commands ------------------------
ARGO_PWD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
          -o jsonpath='{.data.password}' | base64 -d)

cat <<EOF

✅  Install complete!

Argo CD UI
-----------------------------------------------------------------------------
kubectl -n argocd port-forward svc/argocd-server 8080:443 &
Open:  https://localhost:8080
User:  admin
Pass:  $ARGO_PWD

Grafana UI
-----------------------------------------------------------------------------
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80 &
Open:  http://localhost:3000
User:  admin        Pass: prom-operator

Happy GitOps-ing! ✨
EOF

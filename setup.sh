#!/usr/bin/env bash
set -euo pipefail

echo "👉 Creating namespaces"
kubectl apply -f k8s/base/01-namespaces.yaml

echo "👉 Installing Argo CD"
kubectl apply -n argocd -f k8s/argocd/argocd-install.yaml

echo "⏳ Waiting for Argo CD server"
kubectl -n argocd rollout status deploy/argocd-server --timeout=3m

echo "👉 Bootstrapping App‑of‑Apps"
kubectl apply -f k8s/argocd/app-of-apps.yaml

echo "✅ Done. Forward Argo CD:"
echo "kubectl -n argocd port-forward svc/argocd-server 8080:443"

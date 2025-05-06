#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Initialising Terraform..."
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve

echo "✅ Namespaces created."

echo "⎈ Applying base workloads..."
kubectl apply -f k8s/base/01-namespaces.yaml

echo "📦 Deploying GitOps stack (Argo CD)..."
kubectl apply -f k8s/argocd/argocd-install.yaml

echo "ℹ️  Wait for Argo CD pods to be ready, then port‑forward:"
echo "   kubectl -n argocd wait deploy/argocd-server --for condition=Available --timeout=120s"
echo "   kubectl -n argocd port-forward svc/argocd-server 8080:443 &"

echo "🎉 Done!"

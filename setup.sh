#!/bin/bash
set -euo pipefail

echo "🚀 Initialising Terraform..."
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve

echo "✅ Namespaces created."

echo "⎈ Applying Argo CD install manifest..."
kubectl apply -f k8s/argocd/argocd-install.yaml

echo "⏳ Waiting for Argo CD to be ready..."
kubectl -n argocd wait --for=condition=Available deploy/argocd-server --timeout=180s

echo "📦 Applying App of Apps..."
kubectl apply -f k8s/argocd/app-of-apps.yaml

echo "✅ Argo CD bootstrapped and syncing applications!"
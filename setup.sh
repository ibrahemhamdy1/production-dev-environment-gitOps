#!/bin/bash
set -euo pipefail

echo "🚀 Initialising Terraform..."
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve

echo "✅ Namespaces created."

echo "⎈ Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Waiting for Argo CD to be ready..."
kubectl -n argocd wait --for=condition=Available deploy/argocd-server --timeout=180s

echo "🌐 Patching Argo CD service to NodePort..."
kubectl -n argocd patch svc argocd-server -p '{"spec": {"type": "NodePort"}}'

echo "📦 Applying App of Apps config..."
kubectl apply -f k8s/argocd/app-of-apps.yaml

echo "🔐 Getting Argo CD login info..."
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

echo "🎉 Setup complete! Argo CD is accessible on your EC2 public IP with NodePort."
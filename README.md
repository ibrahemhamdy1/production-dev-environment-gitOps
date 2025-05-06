# Argo CD Kubernetes Environment

This repo sets up:

- Namespaces via Terraform
- Argo CD
- Argo CD ApplicationSet to deploy:
  - NGINX Ingress Controller
  - kube-prometheus-stack (Prometheus + Grafana)

## Getting Started

```bash
./scripts/setup.sh
```

Update `repoURL` in `app-of-apps.yaml` to point to your GitHub repo URL.

Port-forward to access Argo CD UI:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443 &
open https://localhost:8080
```

Default username: `admin`
Password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```
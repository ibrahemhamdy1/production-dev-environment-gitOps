# Development Environment with Kubernetes & GitOps

A production‑ready starter kit that provisions core namespaces with **Terraform** and installs
the following via **Flux CD HelmReleases** (or Argo CD, if you prefer):

* **NGINX Ingress Controller** – HA, LoadBalancer service
* **kube‑prometheus‑stack** – Prometheus + Grafana dashboards
* **Argo CD** – GitOps engine (syncs this repo)

## Quick Start (Kind cluster)

```bash
kind create cluster --name dev
git clone https://github.com/yourname/dev_env_k8s_repo.git
cd dev_env_k8s_repo

# Provision namespaces
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve

# Deploy everything else
kubectl apply -R -f k8s/

# Log in to Argo CD
kubectl -n argocd port-forward svc/argocd-server 8080:443 &
open https://localhost:8080
```

> **Default admin password**  
> `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

## Why Terraform *and* GitOps?

| Tool        | Scope                           |
|-------------|---------------------------------|
| Terraform   | Cluster‑lifetime primitives (VPCs, namespaces, IAM) |
| Argo/Flux   | Day‑2 app lifecycle – deployments, Helm, CRDs |

Keeping infrastructure and workloads separate makes upgrades painless and auditable.

## Folder Reference

| Folder | What lives here | Reconcile method |
|--------|-----------------|------------------|
| `terraform/` | Namespaces & low‑level infra | `terraform apply` |
| `k8s/base/` | Shared objects (namespaces)    | `kubectl apply` or GitOps |
| `k8s/ingress/` | Ingress controller (HelmRelease) | GitOps |
| `k8s/metrics/` | kube‑prometheus‑stack         | GitOps |
| `k8s/argocd/` | Argo CD install & app-of-apps | kubectl, then GitOps |

Enjoy and happy shipping!  
_Last updated: 2025-05-06T12:52:53Z_

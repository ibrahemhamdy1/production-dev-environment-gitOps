# Whitehelment – Kubernetes Dev Environment

This repo bootstraps a **fully‑featured development cluster** with:

* **Argo CD** – GitOps (App‑of‑Apps)
* **Ingress NGINX** controller
* **Kube‑Prometheus‑Stack** (Prometheus + Grafana + Alertmanager)
* **Terraform + Helm** for repeatable IaC

<sub>Generated 2025-05-10T07:03:11 UTC</sub>

---

## Quick Start (Recommended)

```bash
cd terraform
terraform init
terraform apply -var="kubeconfig_path=$HOME/.kube/config"
```

Terraform will:

1. Create namespaces `argocd`, `monitoring`, `ingress-nginx`
2. Install Argo CD, Ingress‑NGINX, and kube‑prometheus‑stack via Helm
3. Output the *initial* Argo CD admin password (sensitive)

> **Security:** After first login, change the default admin password  
> *(Settings → Accounts → admin → Change password).*

---

## Local Demo (kubectl)

```bash
./setup.sh
```

This uses plain manifests under `k8s/`.

---

## Repo Layout

| Path | Purpose |
|------|---------|
| `setup.sh` | Local demo bootstrap script |
| `terraform/` | Helm‑based IaC |
| `k8s/` | Manifests consumed by Argo CD |
| `docs/` | Extra docs |

---

📖 Need detail? See [`docs/FILE_OVERVIEW.md`](docs/FILE_OVERVIEW.md)

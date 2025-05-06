# 🤖 Autonomous Development Environment: Kubernetes × GitOps

Unbox a **production‑ready** playground that **self‑provisions** everything you need for cloud‑native experimentation. Core namespaces come online via **Terraform**, while day‑2 services materialize through **Flux CD HelmReleases** — or swap to **Argo CD** with a single flag.

### What You Get out‑of‑the‑box

* **NGINX Ingress Controller** — HA pair behind a `LoadBalancer`
* **kube‑prometheus‑stack** — Prometheus metrics + Grafana dashboards
* **Argo CD** — GitOps control plane (syncs *this* repo)

---

## 🚀 Quick Start (Kind sandbox)

```bash
# Spin up a throw‑away Kubernetes cluster
kind create cluster --name dev

# Clone the blueprint
git clone https://github.com/ibrahemhamdy1/production-dev-environment-gitOps.git
cd production-dev-environment-gitOps

# 1️⃣ Bootstrap core namespaces & RBAC
terraform -chdir=terraform init
terraform -chdir=terraform apply -auto-approve

# 2️⃣ Let GitOps do the heavy lifting
kubectl apply -R -f k8s/

# 3️⃣ Crack open the Argo CD UI
kubectl -n argocd port-forward svc/argocd-server 8080:443 &
open https://localhost:8080
```

> **Initial admin password**
>
> ```bash
> kubectl -n argocd get secret argocd-initial-admin-secret \
>   -o jsonpath="{.data.password}" | base64 -d
> ```

---

## 🤔 Why both Terraform *and* GitOps?

| Engine        | Owns…                                                |
| ------------- | ---------------------------------------------------- |
| **Terraform** | Cluster‑lifetime primitives → VPCs, namespaces, IAM  |
| **Argo/Flux** | Day‑2 app lifecycle → Deployments, Helm charts, CRDs |

Decoupling infra from workloads keeps upgrades **painless** and **auditable**.

---

## 🗂️ Folder Atlas

| Folder         | Contains                               | Reconcile with              |
| -------------- | -------------------------------------- | --------------------------- |
| `terraform/`   | Namespaces & low‑level infra           | `terraform apply`           |
| `k8s/base/`    | Shared objects (namespaces)            | `kubectl apply` / GitOps    |
| `k8s/ingress/` | NGINX Ingress Controller (HelmRelease) | GitOps                      |
| `k8s/metrics/` | kube‑prometheus‑stack                  | GitOps                      |
| `k8s/argocd/`  | Argo CD install & app‑of‑apps          | `kubectl` once, then GitOps |

---

### 🧩 Extending

* Swap NGINX for Traefik or Istio by replacing the HelmRelease manifest.
* Drop in additional HelmReleases under `k8s/apps/` and watch Argo/Flux deploy.
* Fork → plug into your cloud VPC instead of Kind by tweaking `terraform/*.tf`.

> Built with 💚 for rapid prototyping — ship fast, sleep well.

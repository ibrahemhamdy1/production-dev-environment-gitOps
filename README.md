# Whitehelment Dev Environment — **Complete Folder**

This repository satisfies the take‑home task requirements.

## Quick start

```bash
# For microk8s users:
export KUBECONFIG=/var/snap/microk8s/current/credentials/client.config

./setup.sh        # wraps Terraform init+apply
```

When finished, forward ports:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443 &
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80 &
```

Argo CD → `https://localhost:8080`  
Grafana → `http://localhost:3000`

---

## Repo layout

* `setup.sh` – smart installer (auto‑installs Helm, runs Terraform)  
* `terraform/` – namespaces + Helm releases (Argo CD, Ingress, Prometheus)  
* `k8s/` – optional GitOps layer (App‑of‑Apps)  
* `docs/FILE_OVERVIEW.md` – file‑by‑file guide

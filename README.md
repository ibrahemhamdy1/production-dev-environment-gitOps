# DevEnv – Professional GitOps Platform (Cluster‑agnostic)

This repository bootstraps a **production‑grade GitOps stack** onto *any* Kubernetes cluster
that is reachable via your `~/.kube/config`.

| Component | Version (default) |
|-----------|-------------------|
| Argo CD   | 6.7.8 (Helm)      |
| Ingress   | nginx‑ingress 4.10.0 |
| Metrics   | kube‑prometheus‑stack 57.1.1 |

## Quick start (local)

```bash
# 1️⃣ Create a local cluster with kind
make kind

# 2️⃣ Bootstrap Argo CD + monitoring stack via Terraform & Helm
make bootstrap
```

## Folder layout

```
terraform/          # Helm releases + providers (kubeconfig)
kustomize/          # app manifests
scripts/            # helper scripts
Makefile            # convenience targets
```

## Requirements

* Terraform ≥ 1.5
* kubectl ≥ 1.29
* Helm ≥ 3.13
* kind (optional for local clusters)

## Tear down

```bash
make destroy    # Removes helm releases
make kind-clean # Deletes the kind cluster
```

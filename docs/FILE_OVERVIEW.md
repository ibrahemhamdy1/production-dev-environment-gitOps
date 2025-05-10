# File‑by‑File Overview

| Component | Description |
|-----------|-------------|
| **terraform/main.tf** | Providers, namespaces, Helm releases |
| **terraform/values/** | Override files for charts |
| **k8s/base/01-namespaces.yaml** | Core namespaces |
| **k8s/argocd** | Argo CD install & bootstrap |
| **k8s/apps/** | Higher‑level applications managed by Argo CD |

See the inline comments in each file for details.

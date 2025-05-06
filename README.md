# Argo CD Kubernetes Environment (NodePort Enabled)

This repo sets up a GitOps-based Kubernetes environment using:

- ✅ Namespaces via Terraform
- ✅ Argo CD via official manifests
- ✅ Helm-based Applications (NGINX Ingress + kube-prometheus-stack)
- ✅ NodePort-based access to Argo CD UI

## 🚀 Getting Started

1. **Download and run the setup script:**

```bash
chmod +x setup_with_nodeport.sh
./setup_with_nodeport.sh
```

2. **Expose Argo CD via NodePort (automatically handled)**

After setup, Argo CD will be accessible at:

```
https://<YOUR_EC2_PUBLIC_IP>:<NODEPORT>
```

Find the exact NodePort with:

```bash
kubectl -n argocd get svc argocd-server
```

3. **Log in to Argo CD UI**

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

- Username: `admin`
- Password: (use command above)

4. **Monitor GitOps Apps**

- `ingress-nginx` and `kube-prometheus-stack` will be installed automatically.
- View sync status and health in Argo CD UI.

## 📁 Directory Structure

```bash
terraform/                  # Manages namespaces
k8s/
├── base/                   # Namespace definitions
├── argocd/                 # Argo CD install + app-of-apps
└── apps/                   # Helm-based apps deployed by Argo CD
scripts/
└── setup_with_nodeport.sh  # Automated setup script
```

## 🧪 Optional Tests

To verify everything is up:

```bash
kubectl get pods -A
kubectl -n monitoring port-forward svc/kube-prom-stack-grafana 3000:80 &
```

Then open `http://localhost:3000` (user: admin, pass: prom-operator)

---

Happy GitOps-ing! 🚀
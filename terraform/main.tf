###############################################################################
# Terraform - Helm bootstrap for Whitehelment dev cluster
# - Argo CD
# - Ingress NGINX
# - Kube-Prometheus-Stack
###############################################################################

terraform {
  required_version = ">= 1.4.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

###############################################################################
# Variables / Providers
###############################################################################

variable "kubeconfig_path" {
  type        = string
  description = "Absolute path to the kubeconfig that points at your cluster."
  default     = "~/.kube/config"
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

###############################################################################
# Namespaces
###############################################################################

resource "kubernetes_namespace" "argocd" {
  metadata { name = "argocd" }
}

resource "kubernetes_namespace" "monitoring" {
  metadata { name = "monitoring" }
}

resource "kubernetes_namespace" "ingress" {
  metadata { name = "ingress-nginx" }
}

###############################################################################
# Helm releases
###############################################################################

# --- Argo CD ---------------------------------------------------------------
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.3"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [file("${path.module}/values/argocd-values.yaml")]
}

# --- Ingress-NGINX ---------------------------------------------------------
resource "helm_release" "ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.1"
  namespace  = kubernetes_namespace.ingress.metadata[0].name

  create_namespace = false
  values = [file("${path.module}/values/ingress-values.yaml")]
}

# --- Kube-Prometheus-Stack -------------------------------------------------
resource "helm_release" "kps" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "58.2.2"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [file("${path.module}/values/kps-values.yaml")]
}

###############################################################################
# Look up the initial Argo CD admin password (fixes unsupported-attribute error)
###############################################################################

data "kubernetes_secret" "argocd_initial_admin" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
}

###############################################################################
# Outputs
###############################################################################

output "argocd_admin_password" {
  description = "Initial Argo CD admin password"
  value       = base64decode(data.kubernetes_secret.argocd_initial_admin.data["password"])
  sensitive   = true
}

terraform {
  required_version = ">=1.4.0"
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

variable "kubeconfig_path" {
  type        = string
  description = "Path to kubeconfig"
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

# Namespaces
resource "kubernetes_namespace" "argocd" {
  metadata { name = "argocd" }
}

resource "kubernetes_namespace" "monitoring" {
  metadata { name = "monitoring" }
}

resource "kubernetes_namespace" "ingress" {
  metadata { name = "ingress-nginx" }
}

# Argo CD
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.3"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  values     = [file("${path.module}/values/argocd-values.yaml")]
}

# Ingress NGINX
resource "helm_release" "ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.1"
  namespace  = kubernetes_namespace.ingress.metadata[0].name
  create_namespace = false
  values     = [file("${path.module}/values/ingress-values.yaml")]
}

# Kube Prometheus Stack
resource "helm_release" "kps" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "58.2.2"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  values     = [file("${path.module}/values/kps-values.yaml")]
}

output "argocd_admin_password" {
  value       = helm_release.argocd.metadata[0].annotations["initial-first-account-password"]
  sensitive   = true
}

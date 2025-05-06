terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
  }
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}

# Core namespaces managed by Terraform
locals {
  namespaces = [
    "dev",
    "monitoring",
    "argocd",
    "ingress-nginx"
  ]
}

resource "kubernetes_namespace" "core" {
  for_each = toset(local.namespaces)

  metadata {
    name = each.key
    labels = {
      "managed-by" = "terraform"
    }
  }
}

output "created_namespaces" {
  value = [for ns in kubernetes_namespace.core : ns.metadata[0].name]
}

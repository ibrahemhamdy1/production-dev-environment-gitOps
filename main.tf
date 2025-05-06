terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

locals {
  namespaces = ["dev", "monitoring", "argocd", "ingress-nginx"]
}

resource "kubernetes_namespace" "core" {
  for_each = toset(local.namespaces)

  metadata {
    name = each.key
    labels = {
      managed-by = "terraform"
    }
  }
}
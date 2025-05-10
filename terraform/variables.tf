variable "kubeconfig" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "context" {
  description = "Kubeconfig context name (optional)"
  type        = string
  default     = ""
}

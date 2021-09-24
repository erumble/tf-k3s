variable "kubernetes_config_context" {
  description = "Config context to use to connect to kubernetes cluster."
  type        = string
}

variable "kubernetes_config_path" {
  description = "Path to kube config file."
  type        = string
  default     = "~/.kube/config"
}
variable "full_name_override" {
  description = "Set the full name of all resources created."
  type        = string
  default     = ""
}

variable "name_override" {
  description = "Set a name suffix for all resources created. Resources will be named `self-signed-cluster-issuer-{var.name_override}`."
  type        = string
  default     = ""
}

variable "namespace" {
  description = "The namespace to deploy the Helm release to."
  type        = string
  default     = "default"
}

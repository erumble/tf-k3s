variable "ca_issuer_secret" {
  description = "CA Issuer secret to use when _not_ creating a CA."
  type        = string
  default     = ""
}

variable "cluster_issuer_name" {
  description = "Name of the self signed cluster issuer."
  type        = string
}

variable "crl_distribution_points" {
  description = "An array of strings, which identifies the location of the CRL from which the revocation of this certificate can be checked."
  type        = list(string)
  default     = null
}

variable "full_name_override" {
  description = "Set the full name of all resources created."
  type        = string
  default     = ""
}

variable "name_override" {
  description = "Set a name suffix for all resources created. Resources will be named `ca-issuer-{var.name_override}`."
  type        = string
  default     = ""
}

variable "namespace" {
  description = "Namespace to create resources in."
  type        = string
}

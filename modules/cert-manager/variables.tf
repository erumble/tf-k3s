variable "additional_values" {
  description = "List of additional parameter objects to send to the helm chart. These will be yaml encoded."
  type        = list(map(any))
  default     = []
}

variable "chart_version" {
  description = "Version of the Helm chart to deploy."
  type        = string
  default     = "1.5.3"
}

variable "create_namespace" {
  description = "Set to `false` if using an existing namespace."
  type        = bool
  default     = true
}

variable "namespace" {
  description = "The namespace to deploy cert-manager to"
  type        = string
  default     = "cert-manager"
}

variable "namespace_annotations" {
  description = "When creating a namespace, these annotations will be applied to the namespace."
  type        = map(string)
  default     = {}
}

variable "namespace_labels" {
  description = "When creating a namespace, these labels will be applied to the namespace."
  type        = map(string)
  default     = {}
}

variable "pod_affinity_enable" {
  description = "Set to `true` to enable pod afinity rules that will ensure they are not scheduled in the same topology key."
  type        = bool
  default     = true
}

variable "pod_affinity_topology_key" {
  description = "Topology key to use in pod affinity."
  type        = string
  default     = "kubernetes.io/hostname"
}

variable "replica_count" {
  description = "Number of Cert Manager replicas to deploy."
  type        = number
  default     = 2
}

variable "replica_count_cainjector" {
  description = "Number of Cert Manager CA Injector replicas to deploy."
  type        = number
  default     = 2
}

variable "replica_count_webhook" {
  description = "Number of Cert Manager Webhook replicas to deploy."
  type        = number
  default     = 2
}

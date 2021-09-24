variable "additional_values" {
  description = "List of additional parameter objects to send to the helm chart. These will be yaml encoded."
  type        = list(map(any))
  default     = []
}

variable "chart_version" {
  description = "Version of the Helm chart to deploy."
  type        = string
  default     = "2.10.2"
}

variable "create_namespace" {
  description = "Set to `false` if using an existing namespace."
  type        = bool
  default     = true
}

variable "enable_ha" {
  description = "Set to `true` to configure HA."
  type        = bool
  default     = false
}

variable "linkerd_namespace" {
  description = "Namespace that Linkerd is installed in."
  type        = string
  default     = "linkerd"
}

variable "namespace" {
  description = "The namespace to deploy linkerd-viz to"
  type        = string
  default     = "linkerd-viz"
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

variable "prometheus_url" {
  description = "URL for Prometheus"
  type        = string
  default     = null
}

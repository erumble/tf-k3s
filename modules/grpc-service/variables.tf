variable "app_version" {
  description = "The version of the application to deploy."
  type        = string
  default     = "0.0.3"
}

variable "container_port" {
  description = "Port on which the application is listening."
  type        = number
  default     = 9001
}

variable "deployment_annotations" {
  description = "Additional annotations to apply to the deployment."
  type        = map(string)
  default     = {}
}

variable "host" {
  description = "Host name where the service will be, uh, hosted."
  type        = string
}

variable "labels" {
  description = "Additional labels to apply to Kubernetes resources."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "The name of the resources created."
  type        = string
  default     = "dune-quotes"
}

variable "namespace" {
  description = "The name of the namespace to create and deploy to."
  type        = string
}

variable "pod_annotations" {
  description = "Additional annotations to apply to the pods."
  type        = map(string)
  default     = {}
}

variable "replicas" {
  description = "The number of pods to create."
  type        = number
  default     = 2
}

variable "service_account_annotations" {
  description = "Additional annotations to apply to the service account."
  type        = map(string)
  default     = {}
}

variable "service_annotations" {
  description = "Additional annotations to apply to the service."
  type        = map(string)
  default     = {}
}

variable "service_port" {
  description = "Port on which the Kubernetes service listens."
  type        = number
  default     = 9080
}

variable "service_type" {
  description = "Tye type of Kubernetes service to create."
  type        = string
  default     = "ClusterIP"
}

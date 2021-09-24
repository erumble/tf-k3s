# This file contains provider configuration
# Provider version and source info can be found in versions.tf

provider "kubernetes" {
  experiments {
    manifest_resource = true
  }

  config_path    = var.kubernetes_config_path
  config_context = var.kubernetes_config_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubernetes_config_path
    config_context = var.kubernetes_config_context
  }
}

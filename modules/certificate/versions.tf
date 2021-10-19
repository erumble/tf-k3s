terraform {
  experiments = [module_variable_optional_attrs]

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.3"
    }
  }
}

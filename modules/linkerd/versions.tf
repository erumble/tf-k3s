terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.5"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.3"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1"
    }
  }
}

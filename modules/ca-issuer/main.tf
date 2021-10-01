locals {
  ca_issuer_secret = var.ca_issuer_secret != "" ? {
    caIssuerSecret = var.ca_issuer_secret
  } : {}

  full_name_override = var.full_name_override != "" ? {
    fullnameOverride = var.full_name_override
  } : {}

  name_override = var.name_override != "" ? {
    nameOverride = var.name_override
  } : {}

  sets = merge(
    local.ca_issuer_secret,
    local.full_name_override,
    local.name_override,
  )

  helm_release_name = "ca-issuer"
}

resource "helm_release" "ca_issuer" {
  namespace       = var.namespace
  name            = local.helm_release_name
  repository      = "${path.module}/helm/charts"
  chart           = local.helm_release_name
  atomic          = true
  cleanup_on_fail = true

  set {
    name  = "clusterIssuer"
    value = var.cluster_issuer_name
  }

  dynamic "set" {
    for_each = local.sets

    content {
      name  = set.key
      value = set.value
    }
  }

  values = [
    yamlencode({
      crlDistributionPoints = var.crl_distribution_points
    })
  ]
}

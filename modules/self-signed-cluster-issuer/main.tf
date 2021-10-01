locals {
  full_name_override = var.full_name_override != "" ? {
    fullnameOverride = var.full_name_override
  } : {}

  name_override = var.name_override != "" ? {
    nameOverride = var.name_override
  } : {}

  sets = merge(
    local.full_name_override,
    local.name_override,
  )

  helm_release_name = "self-signed-cluster-issuer"
}

resource "helm_release" "self_signed_cluster_issuer" {
  namespace       = var.namespace
  name            = local.helm_release_name
  repository      = "${path.module}/helm/charts"
  chart           = local.helm_release_name
  atomic          = true
  cleanup_on_fail = true

  dynamic "set" {
    for_each = local.sets

    content {
      name  = set.key
      value = set.value
    }
  }
}

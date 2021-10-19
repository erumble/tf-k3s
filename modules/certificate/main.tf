resource "helm_release" "certificate" {
  namespace       = var.namespace
  name            = format("cert.%s", var.name)
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

  values = [for v in local.values : yamlencode(v) if(v != {} && v != null)]
}

resource "kubernetes_namespace" "linkerd_viz" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    annotations = merge(var.namespace_annotations, {
      "linkerd.io/inject"                  = "enabled"
      "viz.linkerd.io/external-prometheus" = var.prometheus_url
    })

    labels = merge(var.namespace_labels, {
      "linkerd.io/extension" = "viz"
    })
  }
}

data "kubernetes_namespace" "linkerd_viz" {
  count = var.create_namespace ? 0 : 1

  metadata {
    name = var.namespace
  }
}

resource "helm_release" "linkerd_viz" {
  namespace       = local.namespace
  name            = "linkerd-viz"
  repository      = "https://helm.linkerd.io/stable"
  chart           = "linkerd-viz"
  version         = var.chart_version
  atomic          = true
  cleanup_on_fail = true

  set {
    name  = "installNamespace"
    value = false
  }

  set {
    name  = "namespace"
    value = local.namespace
  }

  set {
    name  = "linkerdNamespace"
    value = var.linkerd_namespace
  }

  values = [for v in local.helm_values : yamlencode(v) if(v != {} && v != null)]
}

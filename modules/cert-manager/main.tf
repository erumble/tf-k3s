resource "kubernetes_namespace" "this" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    annotations = var.namespace_annotations
    labels      = var.namespace_labels
  }
}

data "kubernetes_namespace" "this" {
  count = var.create_namespace ? 0 : 1

  metadata {
    name = var.namespace
  }
}

resource "helm_release" "this" {
  namespace       = local.namespace
  name            = "cert-manager"
  repository      = "https://charts.jetstack.io"
  chart           = "cert-manager"
  version         = var.chart_version
  atomic          = true
  cleanup_on_fail = true

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "global.podSecurityPolicy.enable"
    value = true
  }

  set {
    name  = "global.leaderElection.namespace"
    value = local.namespace
  }

  set {
    name  = "replicaCount"
    value = var.replica_count
  }

  set {
    name  = "cainjector.replicaCount"
    value = var.replica_count_cainjector
  }

  set {
    name  = "webhook.replicaCount"
    value = var.replica_count_webhook
  }

  values = [for v in local.helm_values : yamlencode(v) if(v != {} && v != null)]
}
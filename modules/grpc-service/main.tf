locals {
  labels = merge(var.labels, local.selector_labels, {
    "app.kubernetes.io/version"    = var.app_version
    "app.kubernetes.io/managed-by" = "Terraform"
  })

  selector_labels = {
    "app.kubernetes.io/name"     = var.name
    "app.kubernetes.io/instance" = "grpc-example"
  }

  name = substr(trim(trimspace(var.name), "-"), 0, 63)
}



resource "kubernetes_service_account" "grpc_service" {
  metadata {
    name        = local.name
    namespace   = var.namespace
    labels      = local.labels
    annotations = var.service_account_annotations
  }
}

resource "kubernetes_service" "grpc_service" {
  metadata {
    name        = local.name
    namespace   = var.namespace
    labels      = local.labels
    annotations = var.service_annotations
  }

  spec {
    type = var.service_type

    selector = local.selector_labels

    port {
      port        = var.service_port
      target_port = "grpc"
      protocol    = "TCP"
      name        = "grpc"
    }
  }
}

resource "kubernetes_deployment" "grpc_service" {
  metadata {
    name        = local.name
    namespace   = var.namespace
    labels      = local.labels
    annotations = var.deployment_annotations
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.selector_labels
    }

    template {
      metadata {
        labels      = local.selector_labels
        annotations = var.pod_annotations
      }

      spec {
        service_account_name = kubernetes_service_account.grpc_service.metadata[0].name

        container {
          name              = local.name
          image             = "gamussa/reactive-quote-service:${var.app_version}"
          image_pull_policy = "IfNotPresent"

          port {
            container_port = var.container_port
            name           = "grpc"
            protocol       = "TCP"
          }

          env {
            name  = "GRPC_SERVER_SECURITY_ENABLED"
            value = false
          }

          env {
            name  = "GRPC_SERVER_PORT"
            value = var.container_port
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "grpc_service_ingress_route" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = local.name
      namespace = var.namespace
      labels    = local.labels
    }

    spec = {
      entryPoints = ["web"]

      routes = [{
        kind  = "Rule"
        match = "Host(`${var.host}`)"

        services = [{
          kind   = "Service"
          name   = kubernetes_service.grpc_service.metadata[0].name
          port   = var.service_port
          scheme = "h2c" # h2c is non-tls grpc
        }]
      }]
    }
  }
}

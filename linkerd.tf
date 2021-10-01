module "linkerd" {
  source = "./modules/linkerd"
}

module "linkerd-viz" {
  source = "./modules/linkerd-viz"

  linkerd_namespace = module.linkerd.namespace

  depends_on = [
    module.linkerd
  ]
}

# Add Traefik to the Linkerd service mesh
resource "kubernetes_manifest" "traefik_pod_annotations" {
  manifest = {
    apiVersion = "helm.cattle.io/v1"
    kind       = "HelmChartConfig"

    metadata = {
      name      = "traefik-linkerd-mesh"
      namespace = "kube-system"

      labels = {
        "app.kubernetes.io/name"       = "traefik-linkerd-mesh"
        "app.kubernetes.io/instance"   = "traefik-linkerd-mesh"
        "app.kubernetes.io/managed-by" = "Terraform"
      }
    }

    spec = {
      valuesContent = yamlencode({
        deployment = {
          podAnnotations = {
            "linkerd.io/inject" = "enabled"
          }
        }
      })
    }
  }

  depends_on = [
    module.linkerd
  ]
}

# Expose Linkerd dashboard
resource "kubernetes_manifest" "linkerd_external_dashboard" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "linkerd-external-dashboard"
      namespace = module.linkerd-viz.namespace

      labels = {
        "app.kubernetes.io/name"       = "linkerd-external-dashboard"
        "app.kubernetes.io/instance"   = "linkerd-external-dashboard"
        "app.kubernetes.io/managed-by" = "Terraform"
      }
    }

    spec = {
      entryPoints = ["web"]
      routes = [{
        kind  = "Rule"
        match = "Host(`linkerd.lvh.me`)"

        services = [{
          kind = "Service"
          name = "web"
          port = 8084
        }]

        middlewares = [{
          name      = kubernetes_manifest.linkerd_external_dashboard_headers.manifest.metadata.name
          namespace = kubernetes_manifest.linkerd_external_dashboard_headers.manifest.metadata.namespace
        }]
      }]
    }
  }

  depends_on = [
    kubernetes_manifest.linkerd_external_dashboard_headers
  ]
}

resource "kubernetes_manifest" "linkerd_external_dashboard_headers" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"

    metadata = {
      name      = "linkerd-external-dashboard-headers"
      namespace = module.linkerd-viz.namespace

      labels = {
        "app.kubernetes.io/name"       = "linkerd-external-dashboard-headers"
        "app.kubernetes.io/instance"   = "linkerd-external-dashboard-headers"
        "app.kubernetes.io/managed-by" = "Terraform"
      }
    }

    spec = {
      headers = {
        customRequestHeaders = {
          Host = "web.linkerd-viz.svc"
        }
      }
    }
  }
}

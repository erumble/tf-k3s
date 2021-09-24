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
    kind = "HelmChartConfig"

    metadata = {
      name = "traefik"
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

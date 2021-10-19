/*
K3s installs Traefik by default into the kube-system namespace.
This allows us to access the Traefik dashboard locally without
having to port forward.
*/

resource "kubernetes_manifest" "insecure_traefik_external_dashboard_ingress_route" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "insecure-traefik-external-dashboard"
      namespace = "kube-system"

      labels = {
        "app.kubernetes.io/name"       = "insecure-traefik-external-dashboard"
        "app.kubernetes.io/instance"   = "insecure-traefik-external-dashboard"
        "app.kubernetes.io/managed-by" = "Terraform"
      }
    }

    spec = {
      entryPoints = ["web"]

      routes = [{
        kind  = "Rule"
        match = "Host(`traefik.lvh.me`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))"

        services = [{
          kind = "TraefikService"
          name = "api@internal"
        }]

        middlewares = [{
          name      = kubernetes_manifest.traefik_middleware_https_redirect.manifest.metadata.name
          namespace = kubernetes_manifest.traefik_middleware_https_redirect.manifest.metadata.namespace
        }]
      }]
    }
  }
}

resource "kubernetes_manifest" "secure_traefik_external_dashboard_ingress_route" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "secure-traefik-external-dashboard"
      namespace = "kube-system"

      labels = {
        "app.kubernetes.io/name"       = "secure-traefik-external-dashboard"
        "app.kubernetes.io/instance"   = "secure-traefik-external-dashboard"
        "app.kubernetes.io/managed-by" = "Terraform"
      }
    }

    spec = {
      entryPoints = ["websecure"]

      routes = [{
        kind  = "Rule"
        match = "Host(`traefik.lvh.me`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))"

        services = [{
          kind = "TraefikService"
          name = "api@internal"
        }]
      }]

      tls = {
        secretName = module.traefik_external_dashboard_cert.secret_name
      }
    }
  }

  depends_on = [
    module.traefik_external_dashboard_cert
  ]
}

module "kube_system_ca_issuer" {
  source = "./modules/ca-issuer"

  cluster_issuer_name = module.self_signed_cluster_issuer.name
  namespace           = "kube-system"

  depends_on = [
    module.self_signed_cluster_issuer,
  ]
}

module "traefik_external_dashboard_cert" {
  source = "./modules/certificate"

  issuer    = module.kube_system_ca_issuer.name
  name      = "traefik.lvh.me"
  namespace = "kube-system"

  dns_names = [
    "traefik.lvh.me"
  ]

  usages = [
    "server auth",
    "client auth",
  ]

  depends_on = [
    module.kube_system_ca_issuer
  ]
}

resource "kubernetes_manifest" "traefik_middleware_https_redirect" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"

    metadata = {
      name      = "https-redirect"
      namespace = "kube-system"

      labels = {
        "app.kubernetes.io/name"       = "https-redirect"
        "app.kubernetes.io/instance"   = "https-redirect"
        "app.kubernetes.io/managed-by" = "Terraform"
      }
    }

    spec = {
      redirectScheme = {
        scheme    = "https"
        permanent = true
        port      = "8443"
      }
    }
  }
}

# Add Traefik to the Linkerd service mesh
resource "kubernetes_manifest" "traefik_pod_annotations" {
  manifest = {
    apiVersion = "helm.cattle.io/v1"
    kind       = "HelmChartConfig"

    metadata = {
      name      = "traefik" # The name must match the name of the Helm chart to modify
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

        # additionalArguments = [
        #   "--log.level=DEBUG",
        #   "--log.format=json",
        # ]
      })
    }
  }

  depends_on = [
    module.linkerd
  ]
}

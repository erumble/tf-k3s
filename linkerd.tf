module "linkerd" {
  source = "./modules/linkerd"
}

module "linkerd_viz" {
  source = "./modules/linkerd-viz"

  linkerd_namespace = module.linkerd.namespace

  depends_on = [
    module.linkerd
  ]
}

module "linkerd_viz_ca_issuer" {
  source = "./modules/ca-issuer"

  cluster_issuer_name = module.self_signed_cluster_issuer.name
  namespace           = module.linkerd_viz.namespace

  depends_on = [
    module.self_signed_cluster_issuer,
  ]
}

module "linkerd_external_dashboard_cert" {
  source = "./modules/certificate"

  issuer    = module.linkerd_viz_ca_issuer.name
  name      = "linkerd.lvh.me"
  namespace = module.linkerd_viz.namespace

  dns_names = [
    "linkerd.lvh.me"
  ]

  usages = [
    "server auth",
    "client auth",
  ]

  depends_on = [
    module.linkerd_viz_ca_issuer
  ]
}

# Expose Linkerd dashboard
resource "kubernetes_manifest" "insecure_linkerd_external_dashboard" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "insecure-linkerd-external-dashboard"
      namespace = module.linkerd_viz.namespace

      labels = {
        "app.kubernetes.io/name"       = "insecure-linkerd-external-dashboard"
        "app.kubernetes.io/instance"   = "insecure-linkerd-external-dashboard"
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
          name      = kubernetes_manifest.linkerd_middleware_https_redirect.manifest.metadata.name
          namespace = kubernetes_manifest.linkerd_middleware_https_redirect.manifest.metadata.namespace
        }]

        # middlewares = [{
        #   name      = kubernetes_manifest.linkerd_external_dashboard_headers.manifest.metadata.name
        #   namespace = kubernetes_manifest.linkerd_external_dashboard_headers.manifest.metadata.namespace
        # }]
      }]
    }
  }

  depends_on = [
    module.linkerd_viz
  ]
}

resource "kubernetes_manifest" "secure_linkerd_external_dashboard" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "secure-linkerd-external-dashboard"
      namespace = module.linkerd_viz.namespace

      labels = {
        "app.kubernetes.io/name"       = "secure-linkerd-external-dashboard"
        "app.kubernetes.io/instance"   = "secure-linkerd-external-dashboard"
        "app.kubernetes.io/managed-by" = "Terraform"
      }
    }

    spec = {
      entryPoints = ["websecure"]

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

      tls = {
        secretName = module.linkerd_external_dashboard_cert.secret_name
      }
    }
  }

  depends_on = [
    module.linkerd_viz
  ]
}

resource "kubernetes_manifest" "linkerd_external_dashboard_headers" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"

    metadata = {
      name      = "linkerd-external-dashboard-headers"
      namespace = module.linkerd_viz.namespace

      labels = {
        "app.kubernetes.io/name"       = "linkerd-external-dashboard-headers"
        "app.kubernetes.io/instance"   = "linkerd-external-dashboard-headers"
        "app.kubernetes.io/managed-by" = "Terraform"
      }
    }

    spec = {
      headers = {
        customRequestHeaders = {
          Host             = "web.linkerd-viz.svc"
          Origin           = "" #<- TODO: CORS might be able to solve this
          l5d-dst-override = "web.linkerd-viz.svc.cluster.local:8084"
        }
      }
    }
  }

  depends_on = [
    module.linkerd_viz
  ]
}

resource "kubernetes_manifest" "linkerd_middleware_https_redirect" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"

    metadata = {
      name      = "https-redirect"
      namespace = module.linkerd_viz.namespace

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

  depends_on = [
    module.linkerd_viz
  ]
}

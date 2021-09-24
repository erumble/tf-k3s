locals {
  namespace = var.create_namespace ? kubernetes_namespace.linkerd_viz[0].metadata[0].name : data.kubernetes_namespace.linkerd_viz[0].metadata[0].name

  default_resources = {
    cpu = {
      limit   = ""
      request = "100m"
    }

    memory = {
      limit   = "250Mi"
      request = "50Mi"
    }
  }

  ha_settings = var.enable_ha ? {
    enablePodAntiAffinity = true

    resources = local.default_resources

    # tap configuration
    tap = {
      replicas  = 3
      resources = local.default_resources
    }

    # web configuration
    dashboard = {
      resources = local.default_resources
    }

    # grafana configuration
    grafana = {
      resources = {
        cpu = local.default_resources.cpu

        memory = {
          limit   = "1024Mi"
          request = "50Mi"
        }
      }
    }

    # prometheus configuration
    prometheus = {
      resources = {
        cpu = {
          limit   = ""
          request = "300m"
        }

        memory = {
          limit   = "8192Mi"
          request = "300Mi"
        }
      }
    }
  } : null

  actual_ha_settings = var.enable_ha ? local.ha_settings : null

  helm_values = flatten([
    local.ha_settings,
    var.additional_values,
  ])
}

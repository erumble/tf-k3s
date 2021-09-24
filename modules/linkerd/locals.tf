locals {
  namespace = var.create_namespace ? kubernetes_namespace.linkerd[0].metadata[0].name : data.kubernetes_namespace.linkerd[0].metadata[0].name

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

  ha_settings = {
    enablePodAntiAffinity = true

    # proxy configuration
    proxy = {
      resources = {
        cpu = {
          request = "100m"
        }

        memory = {
          limit   = "250Mi"
          request = "20Mi"
        }
      }
    }

    # controller configuration
    controllerReplicas   = 3
    controllerResources  = local.default_resources
    destinationResources = local.default_resources
    publicAPIResources   = local.default_resources

    # identity configuration
    identityResources = {
      cpu = local.default_resources.cpu

      memory = {
        limit   = "250Mi"
        request = "10Mi"
      }
    }

    # heartbeat configuration
    heartbeatResources = local.default_resources

    # proxy injector configuration
    proxyInjectorResources = local.default_resources
    webhookFailurePolicy   = "Fail"

    # service profile validator configuration
    spValidatorResources = local.default_resources
  }

  actual_ha_settings = var.enable_ha ? local.ha_settings : null

  helm_values = flatten([
    local.actual_ha_settings,
    var.additional_values,
  ])
}

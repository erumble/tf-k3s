locals {
  namespace = var.create_namespace ? kubernetes_namespace.cert_manager[0].metadata[0].name : data.kubernetes_namespace.cert_manager[0].metadata[0].name

  affinity = var.pod_affinity_enable ? {
    affinity = {
      podAntiAffinity = {
        requiredDuringSchedulingIgnoredDuringExecution = [
          {
            labelSelector = {
              matchExpressions = [
                {
                  key      = "app.kubernetes.io/name"
                  operator = "In"
                  values = [
                    "cert-manager"
                  ]
                }
              ]
            }
            topologyKey = var.pod_affinity_topology_key
          }
        ]
      }
    }
  } : {}

  cainjector_affinity = var.pod_affinity_enable ? {
    cainjector = {
      affinity = { podAntiAffinity = {
        requiredDuringSchedulingIgnoredDuringExecution = [
          {
            labelSelector = {
              matchExpressions = [
                {
                  key      = "app.kubernetes.io/name"
                  operator = "In"
                  values = [
                    "cainjector"
                  ]
                }
              ]
            }
            topologyKey = var.pod_affinity_topology_key
          }
        ]
        }
      }
    }
  } : {}

  webhook_affinity = var.pod_affinity_enable ? {
    webhook = {
      affinity = {
        podAntiAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = [
            {
              labelSelector = {
                matchExpressions = [
                  {
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values = [
                      "webhook"
                    ]
                  }
                ]
              }
              topologyKey = var.pod_affinity_topology_key
            }
          ]
        }
      }
    }
  } : {}

  helm_values = flatten([
    local.affinity,
    local.cainjector_affinity,
    local.webhook_affinity,
    var.additional_values,
  ])
}

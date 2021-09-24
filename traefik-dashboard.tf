/*
K3s installs Traefik by default into the kube-system namespace.
This allows us to access the Traefik dashboard locally without
having to port forward.
*/

resource "kubernetes_manifest" "traefik_external_dashboard" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "traefik-external-dashboard"
      namespace = "kube-system"

      labels = {
        "app.kubernetes.io/name"       = "traefik-external-dashboard"
        "app.kubernetes.io/instance"   = "traefik-external-dashboard"
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
      }]
    }
  }
}

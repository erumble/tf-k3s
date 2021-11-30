resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  namespace       = kubernetes_namespace.argocd.metadata[0].name
  name            = "argo-cd"
  repository      = "https://argoproj.github.io/argo-helm"
  chart           = "argo-cd"
  version         = "3.26.12"
  atomic          = true
  cleanup_on_fail = true

  # ArgoCD will be bootstrapped to manage itself
  lifecycle {
    ignore_changes = all
  }
}

resource "helm_release" "core_applications" {
  namespace       = kubernetes_namespace.argocd.metadata[0].name
  name            = "core-applications"
  repository      = "helm/charts"
  chart           = "core-applications"
  atomic          = true
  cleanup_on_fail = true

  depends_on = [
    helm_release.argocd
  ]
}

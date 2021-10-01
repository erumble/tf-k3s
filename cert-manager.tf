module "cert_manager" {
  source = "./modules/cert-manager"
}

module "self_signed_cluster_issuer" {
  source = "./modules/self-signed-cluster-issuer"

  namespace = module.cert_manager.namespace

  depends_on = [
    module.cert_manager,
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

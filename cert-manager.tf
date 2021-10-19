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

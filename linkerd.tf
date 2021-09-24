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

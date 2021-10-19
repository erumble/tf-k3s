# resource "kubernetes_namespace" "grpc_example" {
#   metadata {
#     name = "dune"

#     annotations = {
#       "linkerd.io/inject" = "enabled"
#     }
#   }
# }

# module "dune_ca_issuer" {
#   source = "./modules/ca-issuer"

#   cluster_issuer_name = module.self_signed_cluster_issuer.name
#   namespace           = kubernetes_namespace.grpc_example.metadata[0].name

#   depends_on = [
#     module.self_signed_cluster_issuer,
#   ]
# }

# module "grpc_example" {
#   source = "./modules/grpc-service"

#   host      = "dune.lvh.me"
#   namespace = kubernetes_namespace.grpc_example.metadata[0].name

#   depends_on = [
#     module.linkerd
#   ]
# }

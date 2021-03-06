# Use Terraform and K3d to manage a K3s Cluster

This will setup a k3s kubernetes cluster on your local machine and setup the following things.
* [Traefik](https://doc.traefik.io/traefik/) for ingress on `localhost:8080` (port is configurable)
* [Linkerd](https://linkerd.io/2.10/overview/) for a service mesh
* [Cert Manager](https://cert-manager.io/docs/) for good old SSL and mTLS

## Prerequisites
* [K3d](https://k3d.io)
* [Jq](https://stedolan.github.io/jq/)
* [Terraform](https://www.terraform.io/docs/index.html)

## Usage
Setup
```
./scripts/setup.zsh -h
```

Cleanup
```
./scripts/cleanup.zsh -h
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ./modules/cert-manager | n/a |
| <a name="module_linkerd"></a> [linkerd](#module\_linkerd) | ./modules/linkerd | n/a |
| <a name="module_linkerd-viz"></a> [linkerd-viz](#module\_linkerd-viz) | ./modules/linkerd-viz | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.linkerd_external_dashboard](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.linkerd_external_dashboard_headers](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.traefik_external_dashboard](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.traefik_pod_annotations](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubernetes_config_context"></a> [kubernetes\_config\_context](#input\_kubernetes\_config\_context) | Config context to use to connect to kubernetes cluster. | `string` | n/a | yes |
| <a name="input_kubernetes_config_path"></a> [kubernetes\_config\_path](#input\_kubernetes\_config\_path) | Path to kube config file. | `string` | `"~/.kube/config"` | no |

## Outputs

No outputs.

This README was generated by (terraform-docs)[https://terraform-docs.io]
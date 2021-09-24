# Create trust anchor
resource "tls_private_key" "trust_anchor" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "trust_anchor" {
  key_algorithm         = tls_private_key.trust_anchor.algorithm
  private_key_pem       = tls_private_key.trust_anchor.private_key_pem
  validity_period_hours = 87600 # 10 years
  is_ca_certificate     = true

  subject {
    common_name = "identity.linkerd.cluster.local"
  }

  allowed_uses = [
    "cert_signing",
    "client_auth",
    "crl_signing",
    "server_auth",
  ]
}

resource "tls_private_key" "issuer" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "issuer" {
  key_algorithm   = tls_private_key.issuer.algorithm
  private_key_pem = tls_private_key.issuer.private_key_pem

  subject {
    common_name = "identity.linkerd.cluster.local"
  }
}

resource "tls_locally_signed_cert" "ca_cert" {
  ca_cert_pem           = tls_self_signed_cert.trust_anchor.cert_pem
  ca_key_algorithm      = tls_self_signed_cert.trust_anchor.key_algorithm
  ca_private_key_pem    = tls_private_key.trust_anchor.private_key_pem
  cert_request_pem      = tls_cert_request.issuer.cert_request_pem
  validity_period_hours = 8760
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "client_auth",
    "crl_signing",
    "server_auth",
  ]
}

# Install Linkerd
resource "kubernetes_namespace" "linkerd" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    annotations = merge(var.namespace_annotations, {
      "linkerd.io/inject" = "disabled"
    })

    labels = merge(var.namespace_labels, {
      "linkerd.io/is-control-plane"          = "true"
      "config.linkerd.io/admission-webhooks" = "disabled"
      "linkerd.io/control-plane-ns"          = "linkerd"
    })
  }
}

data "kubernetes_namespace" "linkerd" {
  count = var.create_namespace ? 0 : 1

  metadata {
    name = var.namespace
  }
}

resource "helm_release" "linkerd" {
  namespace       = local.namespace
  name            = "linkerd2"
  repository      = "https://helm.linkerd.io/stable"
  chart           = "linkerd2"
  version         = var.chart_version
  atomic          = true
  cleanup_on_fail = true

  set {
    name  = "installNamespace"
    value = false
  }

  set {
    name  = "identityTrustAnchorsPEM"
    value = tls_self_signed_cert.trust_anchor.cert_pem
  }

  set {
    name  = "identity.issuer.tls.crtPEM"
    value = tls_locally_signed_cert.ca_cert.cert_pem
  }

  set {
    name  = "identity.issuer.tls.keyPEM"
    value = tls_private_key.issuer.private_key_pem
  }

  set {
    name  = "identity.issuer.crtExpiry"
    value = tls_locally_signed_cert.ca_cert.validity_end_time
  }

  values = [for v in local.helm_values : yamlencode(v) if(v != {} && v != null)]
}

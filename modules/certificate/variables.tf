variable "common_name" {
  description = "CommonName is a common name to be used on the Certificate."
  type        = string
  default     = ""
}

variable "dns_names" {
  description = "DNSNames is a list of DNS subjectAltNames to be set on the Certificate."
  type        = list(string)
  default     = null
}

variable "is_ca" {
  description = "IsCA will mark this Certificate as valid for certificate signing."
  type        = bool
  default     = false
}

variable "issuer" {
  description = "Issuer is a reference to the issuer for this certificate."
  type        = string
}

variable "issuer_kind" {
  description = "The CRD Kind of the issuer."
  type        = string
  default     = "Issuer"

  validation {
    condition     = contains(["Issuer", "ClusterIssuer"], var.issuer_kind)
    error_message = "IssuerKind must be one of Issuer or ClusterIssuer."
  }
}

variable "name" {
  description = "Set the name of all resources created."
  type        = string
}

variable "namespace" {
  description = "The namespace to deploy the Helm release to."
  type        = string
}

variable "private_key" {
  description = "Options to control private keys used for the Certificate."

  type = object({
    algorithm      = string
    encoding       = optional(string)
    rotationPolicy = optional(string)
    size           = optional(number)
  })

  default = null

  validation {
    condition     = var.private_key != null ? contains(["RSA", "ECDSA", "Ed25519"], var.private_key.algorithm) : true
    error_message = "Algorithm must be one of RSA, ECDSA, or Ed25519."
  }

  validation {
    condition     = var.private_key != null ? (can(var.private_key.encoding) ? contains(["PKCS1", "PKCS8"], var.private_key.encoding) : true) : true
    error_message = "Encoding must be one of PKCS1, or PKCS8."
  }

  validation {
    condition     = var.private_key != null ? (can(var.private_key.rotationPolicy) ? contains(["Always", "Never"], var.private_key.rotationPolicy) : true) : true
    error_message = "RotationPolicy must be one of Always, or Never."
  }

  validation {
    condition     = var.private_key != null ? (can(var.private_key.size) ? (var.private_key.algorithm == "RSA" ? contains([2048, 4096, 8192], var.private_key.size) : true) : true) : true
    error_message = "Size must be one of 2048, 4096, or 8192 when Algorithm is RSA."
  }

  validation {
    condition     = var.private_key != null ? (can(var.private_key.size) ? (var.private_key.algorithm == "ECDSA" ? contains([256, 384, 521], var.private_key.size) : true) : true) : true
    error_message = "Size must be one of 256, 384, or 521 when Algorithm is ECDSA."
  }
}

variable "revision_history_limit" {
  description = "RevisionHistoryLimit is the maximum number of CertificateRequest revisions that are maintained in the Certificate's history."
  type        = number
  default     = null
}

variable "secret_name" {
  description = "SecretName is the name of the secret resource that will be automatically created and managed by this Certificate resource."
  type        = string
  default     = ""
}

variable "secret_template" {
  description = "SecretTemplate defines annotations and labels to be propagated to the Kubernetes Secret when it is created or updated."

  type = object({
    annotations = optional(map(string))
    labels      = optional(map(string))
  })

  default = null
}

variable "subject" {
  description = "Full X509 name specification (https://golang.org/pkg/crypto/x509/pkix/#Name)."

  type = object({
    countries           = optional(list(string))
    localities          = optional(list(string))
    organizationalUnits = optional(list(string))
    organizations       = optional(list(string))
    postalCodes         = optional(list(string))
    provinces           = optional(list(string))
    serialNumber        = optional(string)
    streetAddresses     = optional(list(string))
  })

  default = null
}

variable "uris" {
  description = "URIs is a list of URI subjectAltNames to be set on the Certificate."
  type        = list(string)
  default     = null
}

variable "usages" {
  description = ""
  type        = list(string)

  default = [
    "server auth",
    "client auth",
  ]

  validation {
    condition = length(setsubtract(
      var.usages,
      [
        "signing",
        "digital signature",
        "content commitment",
        "key encipherment",
        "key agreement",
        "data encipherment",
        "cert sign",
        "crl sign",
        "encipher only",
        "decipher only",
        "any",
        "server auth",
        "client auth",
        "code signing",
        "email protection",
        "s/mime",
        "ipsec end system",
        "ipsec tunnel",
        "ipsec user",
        "timestamping",
        "ocsp signing",
        "microsoft sgc",
        "netscape sgc",
      ]
    )) == 0

    error_message = "Usages contains invalid values."
  }
}

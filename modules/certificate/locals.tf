locals {
  helm_release_name = "certificate"

  # locals for dynamic set block
  # scalar values can just be `set` as key value pairs
  # lists can be `set` as key value pairs if the list is formatted as a string

  common_name = var.common_name != "" ? {
    commonName = var.common_name
  } : {}

  dns_names = var.dns_names != null ? {
    dnsNames = format("{%s}", join(",", var.dns_names))
  } : {}

  full_name_override = { fullnameOverride = var.name }

  is_ca = { isCA = var.is_ca }

  issuer = { issuer = var.issuer }

  issuer_kind = { issuerKind = var.issuer_kind }

  revision_history_limit = var.revision_history_limit != null ? {
    revisionHistoryLimit = var.revision_history_limit
  } : {}

  secret_name = var.secret_name != "" ? {
    secretName = var.secret_name
  } : {}

  uris = var.uris != null ? {
    uris = format("{%s}", join(",", var.uris))
  } : {}

  usages = {
    usages = format("{%s}", join(",", var.usages))
  }

  sets = merge(
    local.common_name,
    local.dns_names,
    local.full_name_override,
    local.is_ca,
    local.issuer,
    local.issuer_kind,
    local.revision_history_limit,
    local.secret_name,
    local.uris,
    local.usages,
  )

  # locals for values argument
  # objects will get yamlencoded and passed into the values argument

  private_key = var.private_key != null ? {
    privateKey = var.private_key
  } : {}

  secret_template = var.secret_template != null ? {
    secretTemplate = var.secret_template
  } : {}

  subject = var.subject != null ? {
    subject = var.subject
  } : {}

  values = flatten([
    local.private_key,
    local.secret_template,
    local.subject,
  ])
}

output "name" {
  value = var.full_name_override != "" ? var.full_name_override : join("-", compact([local.helm_release_name, var.name_override]))
}

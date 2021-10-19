output "secret_name" {
  value = var.secret_name != "" ? var.secret_name : var.name
}

terraform {
  backend "local" {
    path          = ".terraform/state/default/terraform.tfstate"
    workspace_dir = ".terraform/state/"
  }
}
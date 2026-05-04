# DNS module entry point to ensure Terraform loads variables and module context correctly

locals {
  rg          = var.rg
  hub_vnet_id = var.hub_vnet_id
  location    = var.location
}

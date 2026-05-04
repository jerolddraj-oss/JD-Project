terraform {
  backend "azurerm" {
    resource_group_name  = "k8-backup"
    storage_account_name = "terraformtfstateremote"
    container_name       = "tfstate1979"
    key                  = "terraform.tfstate1979"
  }
}

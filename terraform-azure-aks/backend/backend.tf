terraform {
  backend "azurerm" {
    resource_group_name  = "tf-state-rg"
    storage_account_name = "tfstatestoragejd"
    container_name       = "tfstate"
    key                  = "terraform-azure-aks.tfstate"
  }
}

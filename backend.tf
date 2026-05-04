terraform {
  backend "azurerm" {
    resource_group_name  = "jd-tfstate-rg"
    storage_account_name = "jdtfstate123"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

###################################################
# Azure Remote Backend Configuration
###################################################

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "rdsprojecttfstate"
    container_name       = "tfstate"
    key                  = "rds-poc.terraform.tfstate"
  }
}

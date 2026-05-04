terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "jd-tfstate-rg"
    storage_account_name = "jdtfstate123"
    container_name       = "tfstate"
    key                  = "jd-project.tfstate"
  }
}

provider "azurerm" {
  features {}
}

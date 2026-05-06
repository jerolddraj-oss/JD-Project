terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

############################################
# Resource Group
############################################

resource "azurerm_resource_group" "rds_rg" {
  name     = var.resource_group_name
  location = var.location
}

############################################
# Networking Module
############################################

module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.rds_rg.name
  location            = var.location

  vnet_name = "vnet-rds-poc"

  vnet_address_space       = ["10.10.0.0/16"]
  server_subnet_prefix     = ["10.10.1.0/24"]
  management_subnet_prefix = ["10.10.2.0/24"]
  bastion_subnet_prefix    = ["10.10.3.0/27"]
}

############################################
# Security Module
############################################

module "security" {
  source = "./modules/security"

  resource_group_name = azurerm_resource_group.rds_rg.name
  location            = var.location
  tenant_id           = var.tenant_id

  bastion_subnet_id = module.networking.bastion_subnet_id
}

############################################
# Compute Module
############################################

module "compute" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.rds_rg.name
  location            = var.location

  admin_username = var.admin_username
  admin_password = var.admin_password

  nic_id = module.networking.nic_id
}

############################################
# Storage Module
############################################

module "storage" {
  source = "./modules/storage"

  resource_group_name = azurerm_resource_group.rds_rg.name
  location            = var.location
}

############################################
# Monitoring Module
############################################

module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = azurerm_resource_group.rds_rg.name
  location            = var.location
}

############################################
# Outputs
############################################

output "resource_group_name" {
  value = azurerm_resource_group.rds_rg.name
}

output "virtual_network_name" {
  value = module.networking.vnet_name
}

output "server_subnet_id" {
  value = module.networking.server_subnet_id
}

output "bastion_subnet_id" {
  value = module.networking.bastion_subnet_id
}

output "network_interface_id" {
  value = module.networking.nic_id
}

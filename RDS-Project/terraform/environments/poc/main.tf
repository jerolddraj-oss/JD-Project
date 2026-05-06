###################################################
# Terraform Root Module
###################################################

module "rds_environment" {
  source = "../../"

  #################################################
  # General Configuration
  #################################################

  location        = var.location
  environment     = var.environment
  project_name    = var.project_name

  #################################################
  # Resource Group
  #################################################

  resource_group_name = var.resource_group_name

  #################################################
  # Networking
  #################################################

  hub_vnet_name               = var.hub_vnet_name
  spoke_vnet_name             = var.spoke_vnet_name

  hub_vnet_address_space      = var.hub_vnet_address_space
  spoke_vnet_address_space    = var.spoke_vnet_address_space

  gateway_subnet_prefix       = var.gateway_subnet_prefix
  management_subnet_prefix    = var.management_subnet_prefix
  sessionhost_subnet_prefix   = var.sessionhost_subnet_prefix

  #################################################
  # Security
  #################################################

  allowed_management_ip       = var.allowed_management_ip

  #################################################
  # Virtual Machines
  #################################################

  admin_username              = var.admin_username
  admin_password              = var.admin_password

  vm_size                     = var.vm_size

  rd_gateway_vm_name          = var.rd_gateway_vm_name
  rd_broker_vm_name           = var.rd_broker_vm_name

  rd_session_host_count       = var.rd_session_host_count

  rd_gateway_private_ip       = var.rd_gateway_private_ip
  rd_broker_private_ip        = var.rd_broker_private_ip
}
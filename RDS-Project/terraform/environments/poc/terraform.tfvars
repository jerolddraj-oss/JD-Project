###################################################
# General Configuration
###################################################

location        = "East US"
environment     = "poc"
project_name    = "rds-project"

###################################################
# Resource Group
###################################################

resource_group_name = "rg-rds-poc-eastus"

###################################################
# Networking
###################################################

hub_vnet_name            = "vnet-hub-eastus"
spoke_vnet_name          = "vnet-spoke-eastus"

hub_vnet_address_space   = ["10.0.0.0/16"]
spoke_vnet_address_space = ["10.1.0.0/16"]

gateway_subnet_prefix      = "10.0.0.0/24"
management_subnet_prefix   = "10.0.1.0/24"
sessionhost_subnet_prefix  = "10.1.1.0/24"

###################################################
# Security
###################################################

allowed_management_ip = "YOUR_PUBLIC_IP/32"

###################################################
# Virtual Machines
###################################################

admin_username = "azureadmin"
admin_password = "ChangeM3Immediately!"

vm_size = "Standard_D4s_v5"

rd_gateway_vm_name = "rdgw01"
rd_broker_vm_name  = "rdbroker01"

rd_session_host_count = 2

rd_gateway_private_ip = "10.0.1.10"
rd_broker_private_ip  = "10.0.1.11"
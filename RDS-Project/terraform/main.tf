###################################################
# Resource Group Module
###################################################

module "resource_group" {
  source = "./modules/resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
}

###################################################
# Networking Module
###################################################

module "networking" {
  source = "./modules/networking"

  resource_group_name       = module.resource_group.resource_group_name
  location                  = var.location

  hub_vnet_name             = var.hub_vnet_name
  spoke_vnet_name           = var.spoke_vnet_name

  hub_vnet_address_space    = var.hub_vnet_address_space
  spoke_vnet_address_space  = var.spoke_vnet_address_space

  gateway_subnet_prefix     = var.gateway_subnet_prefix
  management_subnet_prefix  = var.management_subnet_prefix
  sessionhost_subnet_prefix = var.sessionhost_subnet_prefix
}

###################################################
# NSG Module
###################################################

module "nsg" {
  source = "./modules/nsg"

  resource_group_name      = module.resource_group.resource_group_name
  location                 = var.location

  management_subnet_id     = module.networking.management_subnet_id
  sessionhost_subnet_id    = module.networking.sessionhost_subnet_id

  allowed_management_ip    = var.allowed_management_ip

  spoke_vnet_address_space = var.spoke_vnet_address_space[0]
}

###################################################
# Firewall Module
###################################################

module "firewall" {
  source = "./modules/firewall"

  resource_group_name    = module.resource_group.resource_group_name
  location               = var.location

  gateway_subnet_id      = module.networking.gateway_subnet_id

  allowed_management_ip  = var.allowed_management_ip

  hub_vnet_address_space = var.hub_vnet_address_space[0]
}

###################################################
# Peering Module
###################################################

module "peering" {
  source = "./modules/peering"

  resource_group_name = module.resource_group.resource_group_name

  hub_vnet_id         = module.networking.hub_vnet_id
  spoke_vnet_id       = module.networking.spoke_vnet_id

  hub_vnet_name       = module.networking.hub_vnet_name
  spoke_vnet_name     = module.networking.spoke_vnet_name
}

###################################################
# Virtual Machines Module
###################################################

module "virtual_machines" {
  source = "./modules/virtual-machines"

  resource_group_name   = module.resource_group.resource_group_name
  location              = var.location

  admin_username        = var.admin_username
  admin_password        = var.admin_password

  vm_size               = var.vm_size

  rd_gateway_vm_name    = var.rd_gateway_vm_name
  rd_broker_vm_name     = var.rd_broker_vm_name

  rd_session_host_count = var.rd_session_host_count

  management_subnet_id  = module.networking.management_subnet_id
  sessionhost_subnet_id = module.networking.sessionhost_subnet_id

  rd_gateway_private_ip = var.rd_gateway_private_ip
  rd_broker_private_ip  = var.rd_broker_private_ip
}

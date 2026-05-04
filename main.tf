# Root Orchestration - Fixed with required module inputs

resource "azurerm_resource_group" "main" {
  name     = "jd-rg"
  location = var.location
}

# HUB
module "hub" {
  source   = "./modules/hub"
  rg       = azurerm_resource_group.main.name
  location = var.location
}

# SPOKES
module "spoke1" {
  source   = "./modules/spoke"
  name     = "spoke-east"
  location = var.location
  rg       = azurerm_resource_group.main.name
}

module "spoke2" {
  source   = "./modules/spoke"
  name     = "spoke-west"
  location = var.location
  rg       = azurerm_resource_group.main.name
}

module "spoke3" {
  source   = "./modules/spoke"
  name     = "spoke-central"
  location = var.location
  rg       = azurerm_resource_group.main.name
}

# VNET PEERING
module "vnet_peering" {
  source              = "./modules/vnet-peering"
  resource_group_name = azurerm_resource_group.main.name
  hub_vnet_id         = module.hub.vnet_id
  hub_vnet_name       = module.hub.vnet_name

  spokes = {
    spoke1 = {
      id   = module.spoke1.vnet_id
      name = module.spoke1.vnet_name
    }
    spoke2 = {
      id   = module.spoke2.vnet_id
      name = module.spoke2.vnet_name
    }
    spoke3 = {
      id   = module.spoke3.vnet_id
      name = module.spoke3.vnet_name
    }
  }
}

# NETWORK SECURITY
module "network_security" {
  source             = "./modules/network-security"
  rg                 = azurerm_resource_group.main.name
  location           = var.location
  firewall_subnet_id = module.hub.firewall_subnet_id
  public_ip_id       = module.hub.public_ip_id
  hub_vnet_id        = module.hub.vnet_id
}

# FIREWALL RULES
module "security" {
  source    = "./modules/security"
  rg        = azurerm_resource_group.main.name
  location  = var.location
  sp_secret = "dummy-secret"
}

# DNS
module "dns" {
  source      = "./modules/dns"
  rg          = azurerm_resource_group.main.name
  hub_vnet_id = module.hub.vnet_id
  location    = var.location
}

# AKS
module "aks" {
  source   = "./modules/aks"
  name     = "aks-cluster"
  location = var.location
  rg       = azurerm_resource_group.main.name
}

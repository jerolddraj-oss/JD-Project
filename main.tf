# Root Orchestration - Clean & Production Ready

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
  source        = "./modules/spoke"
  name          = "spoke-east"
  location      = var.location
  rg            = azurerm_resource_group.main.name
  address_space = ["10.1.0.0/16"]
  hub_id        = module.hub.vnet_id
}

module "spoke2" {
  source        = "./modules/spoke"
  name          = "spoke-central"
  location      = var.location
  rg            = azurerm_resource_group.main.name
  address_space = ["10.2.0.0/16"]
  hub_id        = module.hub.vnet_id
}

module "spoke3" {
  source        = "./modules/spoke"
  name          = "spoke-europe"
  location      = var.location
  rg            = azurerm_resource_group.main.name
  address_space = ["10.3.0.0/16"]
  hub_id        = module.hub.vnet_id
}

# VNET PEERING
module "vnet_peering" {
  source = "./modules/vnet-peering"

  resource_group_name = azurerm_resource_group.main.name
  hub_vnet_id         = module.hub.vnet_id
  hub_vnet_name       = module.hub.vnet_name

  spokes = {
    east = { id = module.spoke1.vnet_id, name = "spoke-east" }
    central = { id = module.spoke2.vnet_id, name = "spoke-central" }
    europe = { id = module.spoke3.vnet_id, name = "spoke-europe" }
  }

  depends_on = [
    module.hub,
    module.spoke1,
    module.spoke2,
    module.spoke3
  ]
}

# NETWORK SECURITY (FIREWALL CORE)
module "network_security" {
  source = "./modules/network-security"

  location = var.location
  rg       = azurerm_resource_group.main.name

  depends_on = [module.hub]
}

# FIREWALL RULES (SECURITY MODULE)
module "security" {
  source = "./modules/security"

  firewall_name = module.network_security.firewall_name
  rg            = azurerm_resource_group.main.name

  depends_on = [module.network_security]
}

# DNS MODULE
module "dns" {
  source = "./modules/dns"

  location     = var.location
  rg           = azurerm_resource_group.main.name
  hub_vnet_id  = module.hub.vnet_id

  depends_on = [module.hub]
}

# AKS
module "aks" {
  source   = "./modules/aks"
  name     = "aks-cluster"
  location = var.location
  rg       = azurerm_resource_group.main.name

  depends_on = [module.spoke1]
}

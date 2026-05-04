# Root orchestration file

resource "azurerm_resource_group" "main" {
  name     = "jd-rg"
  location = var.location
}

module "hub" {
  source   = "./modules/hub"
  rg       = azurerm_resource_group.main.name
  location = var.location
}

module "spoke1" {
  source        = "./modules/spoke"
  name          = "spoke-east"
  location      = "East US"
  rg            = azurerm_resource_group.main.name
  address_space = ["10.1.0.0/16"]
  hub_id        = module.hub.vnet_id
}

module "spoke2" {
  source        = "./modules/spoke"
  name          = "spoke-central"
  location      = "Central US"
  rg            = azurerm_resource_group.main.name
  address_space = ["10.2.0.0/16"]
  hub_id        = module.hub.vnet_id
}

module "spoke3" {
  source        = "./modules/spoke"
  name          = "spoke-europe"
  location      = "West Europe"
  rg            = azurerm_resource_group.main.name
  address_space = ["10.3.0.0/16"]
  hub_id        = module.hub.vnet_id
}

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
}

module "aks1" {
  source   = "./modules/aks"
  name     = "aks-east"
  location = "East US"
  rg       = azurerm_resource_group.main.name
}

module "network_security" {
  source = "./modules/network-security"

  location = var.location
  rg       = azurerm_resource_group.main.name
}

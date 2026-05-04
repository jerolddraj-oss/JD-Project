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

module "aks1" {
  source   = "./modules/aks"
  name     = "aks-east"
  location = "East US"
  rg       = azurerm_resource_group.main.name
}

module "aks2" {
  source   = "./modules/aks"
  name     = "aks-central"
  location = "Central US"
  rg       = azurerm_resource_group.main.name
}

module "aks3" {
  source   = "./modules/aks"
  name     = "aks-europe"
  location = "West Europe"
  rg       = azurerm_resource_group.main.name
}

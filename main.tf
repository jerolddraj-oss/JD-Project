resource "azurerm_resource_group" "main" {
  name     = "jd-rg"
  location = "East US"
}

module "hub" {
  source   = "./modules/hub"
  rg       = azurerm_resource_group.main.name
  location = "East US"
}

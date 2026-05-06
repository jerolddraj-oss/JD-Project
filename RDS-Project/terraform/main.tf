resource "azurerm_resource_group" "rds_rg" {
  name     = "rg-rds-poc"
  location = "East US"
}

resource "azurerm_virtual_network" "rds_vnet" {
  name                = "vnet-rds-poc"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rds_rg.location
  resource_group_name = azurerm_resource_group.rds_rg.name
}

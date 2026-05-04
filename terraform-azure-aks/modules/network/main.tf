resource "azurerm_virtual_network" "hub" {
  name                = "hub-vnet"
  location            = "japaneast"
  resource_group_name = "rg-aks"
  address_space       = ["10.0.0.0/16"]
}

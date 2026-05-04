resource "azurerm_virtual_network" "spoke" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.1.0/24"]
}

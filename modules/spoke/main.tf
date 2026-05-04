resource "azurerm_virtual_network" "spoke" {
  name                = var.name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.rg
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network_peering" "peer_to_hub" {
  name                      = "peer-to-hub"
  resource_group_name       = var.rg
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = var.hub_id
}

resource "azurerm_virtual_network" "hub" {
  name                = "jd-hub-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.rg
}

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "firewall" {
  name                = "jd-firewall-pip"
  location            = var.location
  resource_group_name = var.rg
  allocation_method   = "Static"
  sku                 = "Standard"
}
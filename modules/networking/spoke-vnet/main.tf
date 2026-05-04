variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_name" { type = string }
variable "address_spaces" { type = list(string) }
variable "tags" { type = map(string) }

resource "azurerm_virtual_network" "spoke" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_spaces
  tags                = var.tags
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["${cidrsubnet(var.address_spaces[0], 8, 1)}"]
}

resource "azurerm_subnet" "vmss_subnet" {
  name                 = "vmss-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = ["${cidrsubnet(var.address_spaces[0], 8, 2)}"]
}

output "vnet_id" {
  value = azurerm_virtual_network.spoke.id
}

output "vnet_name" {
  value = azurerm_virtual_network.spoke.name
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

output "vmss_subnet_id" {
  value = azurerm_subnet.vmss_subnet.id
}

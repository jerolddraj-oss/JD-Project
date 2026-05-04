variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_name" { type = string }
variable "address_spaces" { type = list(string) }
variable "firewall_subnet_name" { type = string }
variable "tags" { type = map(string) }

resource "azurerm_virtual_network" "hub" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_spaces
  tags                = var.tags
}

resource "azurerm_subnet" "firewall" {
  name                 = var.firewall_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.1.0/24"]
  delegations          = []
}

# Subnet for internal load balancer or other hub services
resource "azurerm_subnet" "internal_lb" {
  name                 = "internal-lb-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.2.0/24"]
}

output "vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  value = azurerm_virtual_network.hub.name
}

output "internal_lb_subnet_id" {
  value = azurerm_subnet.internal_lb.id
}

output "firewall_subnet_id" {
  value = azurerm_subnet.firewall.id
}

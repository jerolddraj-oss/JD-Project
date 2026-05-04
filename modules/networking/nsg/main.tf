variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "nsg_name_prefix" { type = string }
variable "tags" { type = map(string) }

# Example NSG for AKS subnet
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "${var.nsg_name_prefix}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

resource "azurerm_network_security_rule" "allow_kube_api" {
  name                        = "Allow-KubeAPI"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "6443"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

# Application Security Group example
resource "azurerm_application_security_group" "app_tier" {
  name                = "${var.nsg_name_prefix}-app"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

output "aks_nsg_id" {
  value = azurerm_network_security_group.aks_nsg.id
}
output "app_asg_id" {
  value = azurerm_application_security_group.app_tier.id
}

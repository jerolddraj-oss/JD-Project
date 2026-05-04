resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.hub_vnet_cidr]
  tags                = var.tags
}
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.spoke_vnet_cidr]
  tags                = var.tags
}
resource "azurerm_subnet" "firewall" { name="AzureFirewallSubnet" resource_group_name=var.resource_group_name virtual_network_name=azurerm_virtual_network.hub.name address_prefixes=["10.0.1.0/24"] }
resource "azurerm_subnet" "appgw" { name="snet-appgw" resource_group_name=var.resource_group_name virtual_network_name=azurerm_virtual_network.hub.name address_prefixes=["10.0.2.0/24"] }
resource "azurerm_subnet" "aks" { name="snet-aks" resource_group_name=var.resource_group_name virtual_network_name=azurerm_virtual_network.spoke.name address_prefixes=["10.1.1.0/24"] }
resource "azurerm_subnet" "vmss" { name="snet-vmss" resource_group_name=var.resource_group_name virtual_network_name=azurerm_virtual_network.spoke.name address_prefixes=["10.1.2.0/24"] }
resource "azurerm_subnet" "monitor" { name="snet-monitor" resource_group_name=var.resource_group_name virtual_network_name=azurerm_virtual_network.spoke.name address_prefixes=["10.1.3.0/24"] }
resource "azurerm_virtual_network_peering" "spoke_to_hub" { name="peer-spoke-to-hub" resource_group_name=var.resource_group_name virtual_network_name=azurerm_virtual_network.spoke.name remote_virtual_network_id=azurerm_virtual_network.hub.id allow_virtual_network_access=true allow_forwarded_traffic=true }
resource "azurerm_virtual_network_peering" "hub_to_spoke" { name="peer-hub-to-spoke" resource_group_name=var.resource_group_name virtual_network_name=azurerm_virtual_network.hub.name remote_virtual_network_id=azurerm_virtual_network.spoke.id allow_virtual_network_access=true allow_forwarded_traffic=true }

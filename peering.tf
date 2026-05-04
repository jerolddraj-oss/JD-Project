resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                      = "hub-to-spoke-east"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = module.hub.vnet_name
  remote_virtual_network_id = module.spoke1.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                      = "hub-to-spoke-central"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = module.hub.vnet_name
  remote_virtual_network_id = module.spoke2.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "hub_to_spoke3" {
  name                      = "hub-to-spoke-europe"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = module.hub.vnet_name
  remote_virtual_network_id = module.spoke3.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

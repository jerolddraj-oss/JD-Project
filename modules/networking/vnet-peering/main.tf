

resource "azurerm_virtual_network_peering" "to_peer" {
  name                      = "${var.vnet_name}-to-${var.peer_vnet_name}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.vnet_name
  remote_virtual_network_id = var.peer_vnet_id
  allow_forwarded_traffic   = var.allow_forwarded_traffic
  allow_gateway_transit     = var.allow_gateway_transit
  use_remote_gateways       = var.use_remote_gateways
  tags                      = var.tags
}

resource "azurerm_virtual_network_peering" "from_peer" {
  name                      = "${var.peer_vnet_name}-to-${var.vnet_name}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.peer_vnet_name
  remote_virtual_network_id = var.vnet_id
  allow_forwarded_traffic   = var.allow_forwarded_traffic
  allow_gateway_transit     = var.allow_gateway_transit
  use_remote_gateways       = var.use_remote_gateways
  tags                      = var.tags
}

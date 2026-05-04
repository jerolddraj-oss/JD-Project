module "vnet_peering" {
  source = "./modules/vnet-peering"

  resource_group_name = azurerm_resource_group.main.name
  hub_vnet_id         = module.hub.vnet_id
  hub_vnet_name       = module.hub.vnet_name

  spokes = {
    east = { id = module.spoke1.vnet_id, name = "spoke-east" }
    central = { id = module.spoke2.vnet_id, name = "spoke-central" }
    europe = { id = module.spoke3.vnet_id, name = "spoke-europe" }
  }
}

module "network_security" {
  source = "./modules/network-security"

  location           = var.location
  rg                 = azurerm_resource_group.main.name
  firewall_subnet_id = module.hub.firewall_subnet_id
  public_ip_id       = azurerm_public_ip.fw_ip.id
}

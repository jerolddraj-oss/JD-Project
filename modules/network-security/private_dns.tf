resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.eastus.azmk8s.io"
  resource_group_name = var.rg
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks_link" {
  name                  = "aks-dns-link"
  resource_group_name   = var.rg
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = var.hub_vnet_id
}

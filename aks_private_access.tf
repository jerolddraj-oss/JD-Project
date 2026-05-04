resource "azurerm_private_endpoint" "aks_api" {
  name                = "aks-private-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.spoke1.subnet_id

  private_service_connection {
    name                           = "aks-connection"
    private_connection_resource_id = module.aks1.id
    subresource_names              = ["management"]
    is_manual_connection           = false
  }
}

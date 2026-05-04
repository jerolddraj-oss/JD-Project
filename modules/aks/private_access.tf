resource "azurerm_private_endpoint" "aks_api" {
  name                = "aks-private-endpoint"
  location            = var.location
  resource_group_name = var.rg
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "aks-connection"
    private_connection_resource_id = var.aks_id
    subresource_names              = ["management"]
    is_manual_connection           = false
  }
}

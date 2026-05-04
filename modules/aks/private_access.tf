resource "azurerm_private_endpoint" "aks_api" {
  count               = var.create_private_cluster && var.subnet_id != null ? 1 : 0
  name                = "aks-private-endpoint"
  location            = var.location
  resource_group_name = var.rg
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "aks-connection"
    private_connection_resource_id = azurerm_kubernetes_cluster.aks_private[0].id
    subresource_names              = ["management"]
    is_manual_connection           = false
  }
}

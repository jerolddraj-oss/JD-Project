resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-aks-hubspoke"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention
  tags                = var.tags
}
resource "azurerm_private_dns_zone" "oms" { name=var.private_dns_zone_name resource_group_name=var.resource_group_name }
resource "azurerm_private_dns_zone_virtual_network_link" "spoke" { name="link-spoke" resource_group_name=var.resource_group_name private_dns_zone_name=azurerm_private_dns_zone.oms.name virtual_network_id=var.spoke_vnet_id }
resource "azurerm_monitor_private_link_scope" "this" { name="ampls-aks" resource_group_name=var.resource_group_name }
resource "azurerm_monitor_private_link_scoped_service" "law" { name="scoped-law" resource_group_name=var.resource_group_name scope_name=azurerm_monitor_private_link_scope.this.name linked_resource_id=azurerm_log_analytics_workspace.this.id }
resource "azurerm_private_endpoint" "this" {
  name="pe-law" location=var.location resource_group_name=var.resource_group_name subnet_id=var.monitor_subnet_id
  private_service_connection { name="pe-law-conn" private_connection_resource_id=azurerm_monitor_private_link_scope.this.id subresource_names=["azuremonitor"] is_manual_connection=false }
}

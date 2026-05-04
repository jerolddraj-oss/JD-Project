resource "azurerm_traffic_manager_profile" "this" {
  name                   = var.traffic_manager_name
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Priority"
  dns_config { relative_name = var.dns_relative_name ttl = 30 }
  monitor_config { protocol="HTTP" port=80 path="/" }
  tags = var.tags
}
resource "azurerm_traffic_manager_external_endpoint" "appgw" {
  name              = "appgw-endpoint"
  profile_id        = azurerm_traffic_manager_profile.this.id
  target            = var.appgw_public_fqdn
  endpoint_location = "eastus"
  priority          = 1
}
resource "azurerm_traffic_manager_external_endpoint" "vmss" {
  for_each          = toset(var.vmss_public_ips)
  name              = "vmss-${replace(each.key, ".", "-")}"
  profile_id        = azurerm_traffic_manager_profile.this.id
  target            = each.key
  endpoint_location = "eastus"
  priority          = 10
}

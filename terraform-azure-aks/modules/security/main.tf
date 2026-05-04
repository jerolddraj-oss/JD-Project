resource "azurerm_public_ip" "firewall" { name="pip-firewall" location=var.location resource_group_name=var.resource_group_name allocation_method="Static" sku="Standard" tags=var.tags }
resource "azurerm_public_ip" "appgw" { name="pip-appgw" location=var.location resource_group_name=var.resource_group_name allocation_method="Static" sku="Standard" tags=var.tags }
resource "azurerm_firewall" "this" {
  name                = "afw-hub"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  ip_configuration { name = "ipconfig" subnet_id = var.firewall_subnet_id public_ip_address_id = azurerm_public_ip.firewall.id }
  tags = var.tags
}
resource "azurerm_firewall_network_rule_collection" "aks_egress" {
  name="allow-aks-egress" azure_firewall_name=azurerm_firewall.this.name resource_group_name=var.resource_group_name priority=100 action="Allow"
  rule { name="dns-and-web" source_addresses=[var.aks_subnet_cidr] destination_ports=["53","80","443"] destination_addresses=["*"] protocols=["TCP","UDP"] }
}
resource "azurerm_web_application_firewall_policy" "this" { name="waf-appgw" location=var.location resource_group_name=var.resource_group_name }
resource "azurerm_application_gateway" "this" {
  name = "agw-hub"
  location = var.location
  resource_group_name = var.resource_group_name
  sku { name="WAF_v2" tier="WAF_v2" capacity=2 }
  gateway_ip_configuration { name="appgw-ipcfg" subnet_id=var.appgw_subnet_id }
  frontend_port { name="port-80" port=80 }
  frontend_ip_configuration { name="frontend" public_ip_address_id=azurerm_public_ip.appgw.id }
  backend_address_pool { name="aks-backend" ip_addresses=[var.appgw_backend_address_pool_ip] }
  backend_http_settings { name="http" cookie_based_affinity="Disabled" port=80 protocol="Http" request_timeout=30 }
  http_listener { name="listener" frontend_ip_configuration_name="frontend" frontend_port_name="port-80" protocol="Http" }
  request_routing_rule { name="rule1" rule_type="Basic" http_listener_name="listener" backend_address_pool_name="aks-backend" backend_http_settings_name="http" priority=100 }
  firewall_policy_id = azurerm_web_application_firewall_policy.this.id
  tags = var.tags
}

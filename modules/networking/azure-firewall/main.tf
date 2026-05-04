variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_id" { type = string }
variable "firewall_name" { type = string }
variable "tags" { type = map(string) }
variable "log_analytics_workspace_id" { type = string }

resource "azurerm_public_ip" "firewall_pip" {
  name                = "${var.firewall_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "this" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  ip_configuration {
    name                 = "configuration"
    subnet_id            = "${var.vnet_id}/subnets/AzureFirewallSubnet"
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }
  tags = var.tags
}

# Route table to force outbound traffic through firewall (forced tunneling)
resource "azurerm_route_table" "forced_tunnel" {
  name                = "${var.firewall_name}-rt"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_route" "default_route" {
  name                   = "default-route-to-firewall"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.forced_tunnel.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

# Diagnostic setting to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "firewall_diag" {
  name                       = "${var.firewall_name}-diag"
  target_resource_id         = azurerm_firewall.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true
  }
  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true
  }
}
output "firewall_id" {
  value = azurerm_firewall.this.id
}
output "firewall_name" {
  value = azurerm_firewall.this.name
}

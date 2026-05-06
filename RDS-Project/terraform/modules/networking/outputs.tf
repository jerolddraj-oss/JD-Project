###################################################
# VNET Outputs
###################################################

output "hub_vnet_id" {
  description = "Hub Virtual Network ID"
  value       = azurerm_virtual_network.hub_vnet.id
}

output "hub_vnet_name" {
  description = "Hub Virtual Network Name"
  value       = azurerm_virtual_network.hub_vnet.name
}

output "spoke_vnet_id" {
  description = "Spoke Virtual Network ID"
  value       = azurerm_virtual_network.spoke_vnet.id
}

output "spoke_vnet_name" {
  description = "Spoke Virtual Network Name"
  value       = azurerm_virtual_network.spoke_vnet.name
}

###################################################
# Subnet Outputs
###################################################

output "gateway_subnet_id" {
  description = "Gateway Subnet ID"
  value       = azurerm_subnet.gateway_subnet.id
}

output "management_subnet_id" {
  description = "Management Subnet ID"
  value       = azurerm_subnet.management_subnet.id
}

output "sessionhost_subnet_id" {
  description = "Session Host Subnet ID"
  value       = azurerm_subnet.sessionhost_subnet.id
}

###################################################
# Route Table Outputs
###################################################

output "hub_route_table_id" {
  description = "Hub Route Table ID"
  value       = azurerm_route_table.hub_route_table.id
}
###################################################
# NSG Outputs
###################################################

output "management_nsg_id" {
  description = "Management NSG ID"
  value       = azurerm_network_security_group.management_nsg.id
}

output "management_nsg_name" {
  description = "Management NSG Name"
  value       = azurerm_network_security_group.management_nsg.name
}

output "sessionhost_nsg_id" {
  description = "Session Host NSG ID"
  value       = azurerm_network_security_group.sessionhost_nsg.id
}

output "sessionhost_nsg_name" {
  description = "Session Host NSG Name"
  value       = azurerm_network_security_group.sessionhost_nsg.name
}
###################################################
# Firewall Outputs
###################################################

output "firewall_id" {
  description = "Azure Firewall ID"
  value       = azurerm_firewall.azure_firewall.id
}

output "firewall_name" {
  description = "Azure Firewall Name"
  value       = azurerm_firewall.azure_firewall.name
}

output "firewall_private_ip" {
  description = "Azure Firewall Private IP"
  value       = azurerm_firewall.azure_firewall.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "Azure Firewall Public IP"
  value       = azurerm_public_ip.firewall_pip.ip_address
}

output "firewall_policy_id" {
  description = "Firewall Policy ID"
  value       = azurerm_firewall_policy.fw_policy.id
}
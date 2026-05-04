output "appgw_public_fqdn" { value = azurerm_public_ip.appgw.fqdn }
output "firewall_public_ip" { value = azurerm_public_ip.firewall.ip_address }

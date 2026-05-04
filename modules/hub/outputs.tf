output "vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "vnet_name" {
  value = azurerm_virtual_network.hub.name
}

output "firewall_subnet_id" {
  value = azurerm_subnet.firewall.id
}

output "public_ip_id" {
  value = azurerm_public_ip.firewall.id
}

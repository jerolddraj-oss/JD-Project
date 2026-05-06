output "resource_group_name" {
  value = azurerm_resource_group.rds_rg.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.rds_vnet.name
}

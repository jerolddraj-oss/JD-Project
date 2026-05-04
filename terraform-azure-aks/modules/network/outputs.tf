output "hub_vnet_id" { value=azurerm_virtual_network.hub.id }
output "spoke_vnet_id" { value=azurerm_virtual_network.spoke.id }
output "firewall_subnet_id" { value=azurerm_subnet.firewall.id }
output "appgw_subnet_id" { value=azurerm_subnet.appgw.id }
output "aks_subnet_id" { value=azurerm_subnet.aks.id }
output "vmss_subnet_id" { value=azurerm_subnet.vmss.id }
output "monitor_subnet_id" { value=azurerm_subnet.monitor.id }

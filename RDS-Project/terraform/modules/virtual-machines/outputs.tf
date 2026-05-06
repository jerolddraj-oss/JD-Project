###################################################
# RD Gateway Outputs
###################################################

output "rd_gateway_private_ip" {
  description = "RD Gateway Private IP"
  value       = azurerm_network_interface.rd_gateway_nic.private_ip_address
}

output "rd_gateway_vm_id" {
  description = "RD Gateway VM ID"
  value       = azurerm_windows_virtual_machine.rd_gateway_vm.id
}

###################################################
# RD Broker Outputs
###################################################

output "rd_broker_private_ip" {
  description = "RD Broker Private IP"
  value       = azurerm_network_interface.rd_broker_nic.private_ip_address
}

output "rd_broker_vm_id" {
  description = "RD Broker VM ID"
  value       = azurerm_windows_virtual_machine.rd_broker_vm.id
}

###################################################
# Session Host Outputs
###################################################

output "session_host_vm_ids" {
  description = "Session Host VM IDs"
  value       = azurerm_windows_virtual_machine.rd_session_host_vm[*].id
}
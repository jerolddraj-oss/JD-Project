output "public_ip_addresses" {
  value = [for nic in azurerm_linux_virtual_machine_scale_set.this.network_interface : nic.ip_configuration[0].public_ip_address[0].name]
}

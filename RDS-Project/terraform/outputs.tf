output "resource_group_name" {
  description = "Resource Group Name"
  value       = module.resource_group.resource_group_name
}

output "hub_vnet_id" {
  description = "Hub VNET ID"
  value       = module.networking.hub_vnet_id
}

output "spoke_vnet_id" {
  description = "Spoke VNET ID"
  value       = module.networking.spoke_vnet_id
}

output "rd_gateway_private_ip" {
  description = "RD Gateway Private IP"
  value       = module.virtual_machines.rd_gateway_private_ip
}

output "rd_broker_private_ip" {
  description = "RD Broker Private IP"
  value       = module.virtual_machines.rd_broker_private_ip
}
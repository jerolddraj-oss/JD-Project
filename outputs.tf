output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vmss_a_public_ip" {
  value = module.vmss_a.public_ip
}

output "vmss_b_public_ip" {
  value = module.vmss_b.public_ip
}

output "traffic_manager_fqdn" {
  value = module.traffic_manager.fqdn
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

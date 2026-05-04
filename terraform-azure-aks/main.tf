locals {
  tags = merge(var.tags, {
    workload = "aks-platform"
  })
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

module "network" {
  source              = "./modules/network"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  hub_vnet_cidr       = var.hub_vnet_cidr
  spoke_vnet_cidr     = var.spoke_vnet_cidr
  tags                = local.tags
}

module "security" {
  source                        = "./modules/security"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.main.name
  tags                          = local.tags
  hub_vnet_id                   = module.network.hub_vnet_id
  firewall_subnet_id            = module.network.firewall_subnet_id
  appgw_subnet_id               = module.network.appgw_subnet_id
  aks_subnet_cidr               = var.aks_subnet_cidr
  appgw_backend_address_pool_ip = module.aks.ingress_private_ip
}

module "aks" {
  source                  = "./modules/aks"
  location                = var.location
  resource_group_name     = azurerm_resource_group.main.name
  aks_name                = var.aks_name
  kubernetes_version      = var.kubernetes_version
  node_count              = var.aks_node_count
  vm_size                 = var.aks_node_vm_size
  zones                   = var.aks_zones
  subnet_id               = module.network.aks_subnet_id
  log_analytics_workspace = module.monitoring.log_analytics_workspace_id
  tags                    = local.tags
}

module "vmss" {
  source              = "./modules/vmss"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = module.network.vmss_subnet_id
  instance_count      = var.vmss_instance_count
  vm_size             = var.vmss_vm_size
  admin_username      = var.vmss_admin_username
  ssh_public_key      = var.vmss_ssh_public_key
  tags                = local.tags
}

module "monitoring" {
  source                 = "./modules/monitoring"
  location               = var.location
  resource_group_name    = azurerm_resource_group.main.name
  tags                   = local.tags
  spoke_vnet_id          = module.network.spoke_vnet_id
  monitor_subnet_id      = module.network.monitor_subnet_id
  private_dns_zone_name  = var.log_analytics_private_dns_zone_name
  log_analytics_sku      = var.log_analytics_sku
  log_analytics_retention = var.log_analytics_retention_days
}

module "traffic_manager" {
  source              = "./modules/traffic_manager"
  resource_group_name = azurerm_resource_group.main.name
  traffic_manager_name = var.traffic_manager_name
  dns_relative_name    = var.traffic_manager_dns_name
  appgw_public_fqdn    = module.security.appgw_public_fqdn
  vmss_public_ips      = module.vmss.public_ip_addresses
  tags                 = local.tags
}

module "keyvault" {
  source                = "./modules/keyvault"
  location              = var.location
  resource_group_name   = azurerm_resource_group.main.name
  key_vault_name        = var.key_vault_name
  tenant_id             = data.azurerm_client_config.current.tenant_id
  object_id             = data.azurerm_client_config.current.object_id
  aks_kubeconfig        = module.aks.kube_config_raw
  app_secret_value      = var.app_secret_value
  tags                  = local.tags
}

data "azurerm_client_config" "current" {}

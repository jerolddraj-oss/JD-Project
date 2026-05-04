locals {
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = local.location
  tags     = local.tags
}

# Log Analytics workspace (module)
module "log_analytics" {
  source = "./modules/monitoring/log-analytics"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  name                = var.log_analytics_name
  tags                = local.tags
}

# Networking: hub vnet
module "hub_vnet" {
  source = "./modules/networking/hub-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  vnet_name           = var.hub_vnet_name
  address_spaces      = var.hub_vnet_address_space
  firewall_subnet_name = var.hub_subnet_firewall_name
  tags                = local.tags
}

# Spokes
module "spoke1_vnet" {
  source = "./modules/networking/spoke-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  vnet_name           = var.spoke1_vnet_name
  address_spaces      = var.spoke1_address_space
  tags                = local.tags
}

module "spoke2_vnet" {
  source = "./modules/networking/spoke-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  vnet_name           = var.spoke2_vnet_name
  address_spaces      = var.spoke2_address_space
  tags                = local.tags
}

# VNet peering hub <-> spokes
module "peering_spoke1" {
  source = "./modules/networking/vnet-peering"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  vnet_name           = module.hub_vnet.vnet_name
  vnet_id             = module.hub_vnet.vnet_id
  peer_vnet_name      = module.spoke1_vnet.vnet_name
  peer_vnet_id        = module.spoke1_vnet.vnet_id
  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = false
  tags = local.tags
}

module "peering_spoke2" {
  source = "./modules/networking/vnet-peering"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  vnet_name           = module.hub_vnet.vnet_name
  vnet_id             = module.hub_vnet.vnet_id
  peer_vnet_name      = module.spoke2_vnet.vnet_name
  peer_vnet_id        = module.spoke2_vnet.vnet_id
  allow_forwarded_traffic = true
  allow_gateway_transit   = false
  use_remote_gateways     = false
  tags = local.tags
}

# Azure Firewall in hub
module "azure_firewall" {
  source = "./modules/networking/azure-firewall"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  vnet_id             = module.hub_vnet.vnet_id
  firewall_name       = "${var.resource_group_name}-azfw"
  tags                = local.tags
  log_analytics_workspace_id = module.log_analytics.workspace_id
}

# NSG module (example for AKS subnet and VMSS)
module "nsg" {
  source = "./modules/networking/nsg"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  tags                = local.tags
  nsg_name_prefix     = "${var.resource_group_name}-nsg"
}

# AKS cluster (in spoke1)
module "aks" {
  source = "./modules/aks/main-cluster"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  name                = var.aks_name
  dns_prefix          = "${var.aks_name}-dns"
  vnet_subnet_id      = module.spoke1_vnet.aks_subnet_id
  kubernetes_version  = var.aks_kubernetes_version
  node_count          = var.aks_node_count
  node_vm_size        = var.aks_node_vm_size
  enable_azure_ad_integration = var.enable_azure_ad_integration
  log_analytics_workspace_id = module.log_analytics.workspace_id
  tags = local.tags
}

# AKS additional node pool module (example)
module "aks_nodepool" {
  source = "./modules/aks/node-pool"
  resource_group_name = azurerm_resource_group.main.name
  cluster_name        = module.aks.cluster_name
  node_pool_name      = "np-spot"
  vm_size             = var.aks_node_vm_size
  node_count          = 2
  tags                = local.tags
}

# VMSS instances (two VMSS in different zones)
module "vmss_a" {
  source = "./modules/compute/vmss"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  name                = "${var.resource_group_name}-vmss-a"
  instance_count      = var.vmss_instance_count
  vm_size             = var.vmss_vm_size
  subnet_id           = module.spoke2_vnet.vmss_subnet_id
  zones               = ["1"]
  tags                = local.tags
  log_analytics_workspace_id = module.log_analytics.workspace_id
}

module "vmss_b" {
  source = "./modules/compute/vmss"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  name                = "${var.resource_group_name}-vmss-b"
  instance_count      = var.vmss_instance_count
  vm_size             = var.vmss_vm_size
  subnet_id           = module.spoke2_vnet.vmss_subnet_id
  zones               = ["2"]
  tags                = local.tags
  log_analytics_workspace_id = module.log_analytics.workspace_id
}

# Internal Load Balancer for AKS/VMSS backends (example)
resource "azurerm_lb" "internal" {
  name                = "${var.resource_group_name}-internal-lb"
  location            = local.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "internalFrontend"
    subnet_id            = module.hub_vnet.internal_lb_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = local.tags
}

# Traffic Manager
module "traffic_manager" {
  source = "./modules/traffic/traffic-manager"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  profile_name        = var.traffic_manager_profile_name
  endpoints = [
    {
      name = "${module.vmss_a.name}-endpoint"
      type = "external"
      target = module.vmss_a.public_ip
      priority = 1
      geo = "GEO_EUROPE"
    },
    {
      name = "${module.vmss_b.name}-endpoint"
      type = "external"
      target = module.vmss_b.public_ip
      priority = 2
      geo = "GEO_ASIA"
    }
  ]
  tags = local.tags
}

# Key Vault
module "key_vault" {
  source = "./modules/security/key-vault"
  resource_group_name = azurerm_resource_group.main.name
  location            = local.location
  name                = var.key_vault_name
  tenant_id           = var.tenant_id
  object_ids          = [] # populate with service principal or user object IDs as needed
  tags                = local.tags
}

# Diagnostic settings for major resources (example for AKS, VMSS, Firewall)
resource "azurerm_monitor_diagnostic_setting" "aks_diag" {
  name               = "${module.aks.cluster_name}-diag"
  target_resource_id = module.aks.cluster_id
  log_analytics_workspace_id = module.log_analytics.workspace_id

  log {
    category = "kube-apiserver"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
}

# Additional diagnostic settings for VMSS and firewall
resource "azurerm_monitor_diagnostic_setting" "vmss_a_diag" {
  name = "${module.vmss_a.name}-diag"
  target_resource_id = module.vmss_a.vmss_id
  log_analytics_workspace_id = module.log_analytics.workspace_id
  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy { enabled = false }
  }
}

resource "azurerm_monitor_diagnostic_setting" "firewall_diag" {
  name = "${module.azure_firewall.firewall_name}-diag"
  target_resource_id = module.azure_firewall.firewall_id
  log_analytics_workspace_id = module.log_analytics.workspace_id
  log {
    category = "AzureFirewallNetworkRule"
    enabled  = true
    retention_policy { enabled = false }
  }
  log {
    category = "AzureFirewallApplicationRule"
    enabled  = true
    retention_policy { enabled = false }
  }
}

# Note: Outputs for VMSS public IPs, Traffic Manager FQDN, and Key Vault URI
# should be declared in outputs.tf (root) to avoid duplicate definitions.

output "aks_kubeconfig_instructions" {
  value = "Use az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${module.aks.cluster_name} to configure kubectl"
}

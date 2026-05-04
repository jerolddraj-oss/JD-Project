variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "name" { type = string }
variable "dns_prefix" { type = string }
variable "vnet_subnet_id" { type = string }
variable "kubernetes_version" { type = string }
variable "node_count" { type = number }
variable "node_vm_size" { type = string }
variable "enable_azure_ad_integration" { type = bool default = true }
variable "log_analytics_workspace_id" { type = string }
variable "tags" { type = map(string) }

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name       = "agentpool"
    node_count = var.node_count
    vm_size    = var.node_vm_size
    vnet_subnet_id = var.vnet_subnet_id
    availability_zones = ["1","2","3"]
    type = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count = 1
    max_count = 5
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    load_balancer_sku = "standard"
    outbound_type = "userDefinedRouting"
  }

  role_based_access_control {
    enabled = true
  }

  azure_active_directory {
    managed = var.enable_azure_ad_integration
    # If integrating with existing AAD, additional fields (admin_group_object_ids) can be provided
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  tags = var.tags
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

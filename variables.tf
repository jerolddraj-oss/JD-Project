variable "subscription_id" { type = string }
variable "tenant_id"       { type = string }
variable "client_id"       { type = string }
variable "client_secret"   { type = string, sensitive = true }

variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  type    = string
  default = "rg-hub-spoke"
}

# Backend state variables
variable "backend_resource_group" { type = string }
variable "backend_storage_account" { type = string }
variable "backend_container" { type = string }
variable "backend_key" { type = string }

# Tagging
variable "tags" {
  type = map(string)
  default = {
    Project     = "example-project"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Networking
variable "hub_vnet_name" { type = string default = "hub-vnet" }
variable "hub_vnet_address_space" { type = list(string) default = ["10.0.0.0/16"] }
variable "hub_subnet_firewall_name" { type = string default = "AzureFirewallSubnet" }
variable "spoke1_vnet_name" { type = string default = "spoke1-vnet" }
variable "spoke1_address_space" { type = list(string) default = ["10.1.0.0/16"] }
variable "spoke2_vnet_name" { type = string default = "spoke2-vnet" }
variable "spoke2_address_space" { type = list(string) default = ["10.2.0.0/16"] }

# AKS
variable "aks_name" { type = string default = "aks-cluster" }
variable "aks_node_count" { type = number default = 3 }
variable "aks_node_vm_size" { type = string default = "Standard_D4s_v3" }
variable "aks_kubernetes_version" { type = string default = "1.26.4" }

# VMSS
variable "vmss_count" { type = number default = 2 }
variable "vmss_instance_count" { type = number default = 2 }
variable "vmss_vm_size" { type = string default = "Standard_D2s_v3" }

# Traffic Manager
variable "traffic_manager_profile_name" { type = string default = "tm-profile" }

# Log Analytics
variable "log_analytics_name" { type = string default = "la-workspace" }

# Key Vault
variable "key_vault_name" { type = string default = "kv-terraform" }

# Misc
variable "enable_azure_ad_integration" { type = bool default = true }
variable "environment" { type = string default = "dev" }

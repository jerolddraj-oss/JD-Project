variable "location" { type = string default = "eastus" }
variable "resource_group_name" { type = string default = "rg-aks-hubspoke" }
variable "hub_vnet_cidr" { type = string default = "10.0.0.0/16" }
variable "spoke_vnet_cidr" { type = string default = "10.1.0.0/16" }
variable "aks_subnet_cidr" { type = string default = "10.1.1.0/24" }
variable "aks_name" { type = string default = "aks-spoke-cluster" }
variable "kubernetes_version" { type = string default = "1.30.9" }
variable "aks_node_count" { type = number default = 2 }
variable "aks_node_vm_size" { type = string default = "Standard_D4s_v5" }
variable "aks_zones" { type = list(string) default = ["1","2"] }
variable "vmss_instance_count" { type = number default = 2 }
variable "vmss_vm_size" { type = string default = "Standard_B2s" }
variable "vmss_admin_username" { type = string default = "azureuser" }
variable "vmss_ssh_public_key" { type = string }
variable "traffic_manager_name" { type = string default = "tm-aks-hubspoke" }
variable "traffic_manager_dns_name" { type = string default = "aks-hubspoke" }
variable "log_analytics_private_dns_zone_name" { type = string default = "privatelink.oms.opinsights.azure.com" }
variable "log_analytics_sku" { type = string default = "PerGB2018" }
variable "log_analytics_retention_days" { type = number default = 30 }
variable "key_vault_name" { type = string default = "kvakshubspoke001" }
variable "app_secret_value" { type = string sensitive = true }
variable "tags" {
  type = map(string)
  default = {
    environment = "dev"
    project     = "jd-aks-platform"
    managed_by  = "terraform"
  }
}

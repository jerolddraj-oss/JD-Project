variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "name" { type = string }
variable "tags" { type = map(string) }

resource "azurerm_log_analytics_workspace" "la" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

output "workspace_id" {
  value = azurerm_log_analytics_workspace.la.id
}

output "workspace_primary_shared_key" {
  value     = azurerm_log_analytics_workspace.la.primary_shared_key
  sensitive = true
}

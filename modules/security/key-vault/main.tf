variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "name" { type = string }
variable "tenant_id" { type = string }
variable "object_ids" { type = list(string) default = [] }
variable "tags" { type = map(string) }

resource "azurerm_key_vault" "kv" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  soft_delete_enabled         = true
  soft_delete_retention_days  = 90
  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = ["get","list","create","delete","update","import","backup","restore","recover"]
    secret_permissions = ["get","list","set","delete","backup","restore","recover"]
  }
  tags = var.tags
}

data "azurerm_client_config" "current" {}

# Example secret for AKS admin (you may store SSH keys or other secrets)
resource "azurerm_key_vault_secret" "example" {
  name         = "example-secret"
  value        = "REPLACE_WITH_SECURE_VALUE"
  key_vault_id = azurerm_key_vault.kv.id
}

output "vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

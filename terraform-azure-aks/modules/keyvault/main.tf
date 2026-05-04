resource "azurerm_key_vault" "this" {
  name = var.key_vault_name
  location = var.location
  resource_group_name = var.resource_group_name
  tenant_id = var.tenant_id
  sku_name = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled = true
  tags = var.tags
}
resource "azurerm_key_vault_access_policy" "operator" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id = var.tenant_id
  object_id = var.object_id
  secret_permissions = ["Get","List","Set","Delete","Recover","Backup","Restore","Purge"]
}
resource "azurerm_key_vault_secret" "aks_kubeconfig" { name="aks-kubeconfig" value=var.aks_kubeconfig key_vault_id=azurerm_key_vault.this.id }
resource "azurerm_key_vault_secret" "app_secret" { name="application-secret" value=var.app_secret_value key_vault_id=azurerm_key_vault.this.id }

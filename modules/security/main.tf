resource "azurerm_key_vault" "kv" {
  name                        = "jd-kv"
  location                    = var.location
  resource_group_name         = var.rg
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault_secret" "sp_secret" {
  name         = "sp-secret"
  value        = var.sp_secret
  key_vault_id = azurerm_key_vault.kv.id
}

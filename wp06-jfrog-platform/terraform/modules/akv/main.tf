resource "azurerm_key_vault" "akv" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.rg_name
  sku_name            = var.sku_name
  tenant_id           = var.tenant_id

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "admin_principal_access" {
  key_vault_id = azurerm_key_vault.akv.id
  tenant_id    = var.tenant_id
  object_id    = var.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set"
  ]
  key_permissions = [
    "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete"
  ]
  certificate_permissions = [
    "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete"
  ]
}
data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azuread_service_principal" "sp" {
  display_name = var.service_principal_name
}

module "akv" {
  source = "../../modules/akv"

  key_vault_name = var.name
  location       = data.azurerm_resource_group.rg.location
  rg_name        = data.azurerm_resource_group.rg.name
  tenant_id      = var.tenant_id
  object_id      = data.azuread_service_principal.sp.object_id
  tags           = data.azurerm_resource_group.rg.tags
}

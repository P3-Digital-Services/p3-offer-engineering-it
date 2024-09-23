# Module to create Azure Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = var.sku
  admin_enabled            = var.admin_enabled
  tags = var.tags
}

resource "azurerm_role_assignment" "acrpush" {
  principal_id                     = var.principal_id
  role_definition_name             = "AcrPush"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "crrc" {
  principal_id                     = var.principal_id
  role_definition_name             = "Container Registry Repository Contributor"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

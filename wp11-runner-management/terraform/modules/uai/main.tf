resource "azurerm_user_assigned_identity" "uai" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = var.name
  tags                = var.tags
}
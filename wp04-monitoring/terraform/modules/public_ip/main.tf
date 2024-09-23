resource "azurerm_public_ip" "pip" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.allocation_method
  zones               = var.zones
  sku                 = var.sku
  tags                = var.tags
}

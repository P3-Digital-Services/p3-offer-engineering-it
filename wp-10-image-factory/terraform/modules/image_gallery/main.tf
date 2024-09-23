
resource "azurerm_shared_image_gallery" "image_gallery" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
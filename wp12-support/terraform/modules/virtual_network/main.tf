resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.virtual_address_space
  tags                = var.tags

  subnet {
    name           = var.subnet_name
    address_prefix = var.subnet_cidr
    security_group = var.subnet_nsg
  }
}

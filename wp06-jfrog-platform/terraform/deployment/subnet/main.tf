module "subnet" {
  source           = "../../modules/subnet"
  subnet_name      = var.subnet_name
  rg_name          = var.rg_name
  vnet_name        = var.vnet_name
  address_prefixes = var.address_prefixes
  location         = data.azurerm_resource_group.rg.location
  tags             = data.azurerm_resource_group.rg.tags
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

module "name" {
  source             = "../../modules/vnet"
  vnet_name          = var.vnet_name
  location           = data.azurerm_resource_group.rg.location
  rg_name            = var.rg_name
  vnet_address_space = var.vnet_address_space
  tags               = data.azurerm_resource_group.rg.tags
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code}-vnet-01"
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = ["${var.vnet_address_space}"]
  tags                = var.project_tag
}

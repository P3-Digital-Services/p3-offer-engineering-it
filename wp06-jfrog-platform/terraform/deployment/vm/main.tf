module "vm" {
  source    = "../../modules/vm"
  name      = var.name
  location  = data.azurerm_resource_group.rg.location
  rg_name   = var.rg_name
  subnet_id = data.azurerm_subnet.subnet.id
  tags      = data.azurerm_resource_group.rg.tags
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.rg_name
}


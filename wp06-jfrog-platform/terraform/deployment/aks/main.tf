module "aks" {
  source                     = "../../modules/aks"
  name                       = var.name
  location                   = data.azurerm_resource_group.rg.location
  rg_name                    = data.azurerm_resource_group.rg.name
  kubernetes_version         = var.kubernetes_version
  subnet_id                  = data.azurerm_subnet.subnet.id
  admin_group_object_ids     = var.admin_group_object_ids
  tags                       = data.azurerm_resource_group.rg.tags
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.rg_name
}

data "azurerm_user_assigned_identity" "aks" {
  name                = "${module.aks.aks_name}-agentpool"
  resource_group_name = module.aks.aks_node_resource_group
}
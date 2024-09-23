locals {
  subnets = {
    for subnet in var.subnets : subnet.subnet_name => subnet
  }
  azurerm_subnets = { for s in azurerm_subnet.subnet : s.name => s }
}
resource "azurerm_subnet" "subnet" {
  for_each                        = local.subnets
  name                            = "${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code}-${each.value.subnet_name}-01"
  resource_group_name             = var.rg_name
  virtual_network_name            = var.vnet_name
  address_prefixes                = ["${each.value.subnet_address_prefixes}"]
  default_outbound_access_enabled = each.value.is_private_subnet
}

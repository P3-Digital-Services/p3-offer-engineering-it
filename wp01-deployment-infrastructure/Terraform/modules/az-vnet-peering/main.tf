resource "azurerm_virtual_network_peering" "vnet_peering" {
    name = "${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code}-${var.vnet_peering_name}-01"
    resource_group_name = var.rg_name
    virtual_network_name = var.vnet_name
    remote_virtual_network_id = var.remote_virtual_network_id
    allow_virtual_network_access = var.is_allow_virtual_network_access
    allow_forwarded_traffic = var.is_allow_forwarded_traffic
    allow_gateway_transit = var.is_allow_gateway_transit
}

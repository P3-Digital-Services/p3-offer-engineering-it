locals {
    network_security_groups = {
        for nsg in var.network_security_groups : nsg.nsg_name => nsg
    }
    azurerm_nsgs = { for nsg in azurerm_network_security_group.nsg : nsg.name => nsg }
}
resource "azurerm_network_security_group" "nsg" {
    for_each = local.network_security_groups
    name = "${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code}-${each.value.nsg_name}-nsg-01"
    location = var.rg_location
    resource_group_name = var.rg_name
    dynamic "security_rule" {
        for_each = each.value.security_rules
        content {
            name = security_rule.value.name
            priority = security_rule.value.priority
            direction = security_rule.value.direction
            access = security_rule.value.access
            protocol = security_rule.value.protocol
            source_port_range = security_rule.value.source_port_range
            destination_port_range = security_rule.value.destination_port_range
            source_address_prefix = security_rule.value.source_address_prefix
            destination_address_prefix = security_rule.value.destination_address_prefix
        }
    }
    tags = var.project_tag
}

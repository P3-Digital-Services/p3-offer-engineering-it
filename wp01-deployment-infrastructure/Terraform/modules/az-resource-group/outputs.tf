output "rg_id" {
    value = azurerm_resource_group.cariad-rg.id
    description = "The resource group ID"
}
output "rg_name" {
    value = azurerm_resource_group.cariad-rg.name
    description = "The resource group name"
}

output "rg_location" {
    value = azurerm_resource_group.cariad-rg.location
    description = "The resource group location"
}
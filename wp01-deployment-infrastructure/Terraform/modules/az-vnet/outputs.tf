output "vnet_name" {
    value = azurerm_virtual_network.vnet.name
    description = "The Vnet name"
}
output "vnet_id" {
    value = azurerm_virtual_network.vnet.id
    description = "The Vnet Id"
}
output "id" {
  value = azurerm_subnet.subnet.id
}

output "vnet_name" {
  value = azurerm_subnet.subnet.virtual_network_name
}
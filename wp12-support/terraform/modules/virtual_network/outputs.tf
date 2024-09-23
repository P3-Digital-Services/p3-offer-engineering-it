output "id" {
  value = azurerm_virtual_network.vnet.id
}
output "name" {
  value = azurerm_virtual_network.vnet.name
}
output "subnet_id" {
  value = azurerm_virtual_network.vnet.subnet[*].id
}

output "id" {
  value = azurerm_virtual_network.vnet.id
}

output "name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnet_id" {
  value = azurerm_subnet.main_subnet.id
}

output "firewall_subnet_id" {
  value = azurerm_subnet.fwsubnet.id
}

output "firewall_mgmt_subnet_id" {
  value = azurerm_subnet.fwmgmtsubnet.id
}
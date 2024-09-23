output "id" {
  value = azurerm_linux_virtual_machine.vm.id
}
output "name" {
  value = azurerm_linux_virtual_machine.vm.name
}
output "admin_username" {
  value = azurerm_linux_virtual_machine.vm.admin_username
}
output "admin_password" {
  value = azurerm_linux_virtual_machine.vm.admin_password
}
output "private_ip" {
  value = azurerm_linux_virtual_machine.vm.private_ip_address
}

output "public_ip_address_id" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}
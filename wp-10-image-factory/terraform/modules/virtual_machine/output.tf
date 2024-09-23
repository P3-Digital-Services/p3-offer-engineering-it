output "id" {
  value = azurerm_linux_virtual_machine.vm.id
}
output "name" {
  value = azurerm_linux_virtual_machine.vm.name
}

output "identity_principal_id" {
  value = azurerm_linux_virtual_machine.vm.identity.0.principal_id
}

output "private_ip_address" {
  value = azurerm_network_interface.nic.*.private_ip_address
}




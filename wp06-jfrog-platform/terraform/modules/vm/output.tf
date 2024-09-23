output "public_ip" {
  value = azurerm_linux_virtual_machine.linux_agent.public_ip_address
}

output "private_ip" {
  value = azurerm_linux_virtual_machine.linux_agent.private_ip_address
}
output "public_ip" {
  value = azurerm_windows_virtual_machine.this.public_ip_address
}

output "private_ip" {
  value = azurerm_windows_virtual_machine.this.private_ip_address
}
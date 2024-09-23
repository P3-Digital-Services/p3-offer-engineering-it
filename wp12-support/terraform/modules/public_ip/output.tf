output "id" {
  value = azurerm_public_ip.pip.id
}

# data "azurerm_public_ip" "test" {
#   name                = var.name
#   resource_group_name = var.resource_group_name
# }

# output "public_ip_address_id" {
#     value = data.azurerm_public_ip.test.ip_address
# }
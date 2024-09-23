resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.address_prefixes
}

# resource "azurerm_network_security_group" "nsg" {
#   name                = "${var.subnet_name}-nsg"
#   resource_group_name = var.rg_name
#   location            = var.location

#   security_rule {
#     name                       = "AllowSSH"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "22"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
#   tags = var.tags
# }

# resource "azurerm_subnet_network_security_group_association" "nsg_association" {
#   subnet_id                 = azurerm_subnet.subnet.id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }

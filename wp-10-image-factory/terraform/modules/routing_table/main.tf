resource "azurerm_route_table" "default" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  route {
    name                    = "default"
    address_prefix          = "0.0.0.0/0"
    next_hop_in_ip_address  = var.firewall_private_ip
    next_hop_type           = "VirtualAppliance"
    }
}


resource "azurerm_subnet_route_table_association" "example" {
  subnet_id      = var.subnet_id
  route_table_id = azurerm_route_table.default.id
}
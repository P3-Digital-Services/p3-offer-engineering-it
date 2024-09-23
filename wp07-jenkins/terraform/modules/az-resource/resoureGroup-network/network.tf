resource "azurerm_network_security_group" "wp07_sg01" {
  name                = "wp07_security_group_01"
  location            = azurerm_resource_group.WP07_rg.location
  resource_group_name = azurerm_resource_group.WP07_rg.name
  tags = {
    ApplicationName = "AKS-Jenkins"
    OwnerService = "LinhNMD"
    ProjectID = "WB07"
  }
}

resource "azurerm_virtual_network" "wp07_vpc" {
  name                = "wp07_network"
  location            = azurerm_resource_group.WP07_rg.location
  resource_group_name = azurerm_resource_group.WP07_rg.name
  address_space       = ["10.1.0.0/16"]
#  subnet_prefixes = ["10.1.0.0/24"]

  subnet {
    name             = "subnet1"
    address_prefixes = ["10.1.1.0/24"]
    security_group   = azurerm_network_security_group.wp07_sg01.id
  }

  subnet {
    name             = "subnet2"
    address_prefixes = ["10.1.2.0/24"]
    security_group   = azurerm_network_security_group.wp07_sg01.id
  }

  tags = {
    ApplicationName = "AKS-Jenkins"
    OwnerService = "LinhNMD"
    ProjectID = "WB07"
  }
}

output "vpc_id" {
  description = "vpc id"
  value       = azurerm_virtual_network.wp07_vpc.id
}
output "subnet01" {
  description = "The Resource Group name."
  value       = azurerm_virtual_network.wp07_vpc.subnet.*.id[0]
}

output "subnet02" {
  description = "The Resource Group name."
  value       = azurerm_virtual_network.wp07_vpc.subnet.*.id[1]
}
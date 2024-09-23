resource "azurerm_public_ip" "fwpip" {
  name                = var.pipname
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "fwmgmtpip" {
  name                = "${var.pipname}-mgmt"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}



resource "azurerm_firewall" "fw" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Basic"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.fwpip.id
  }

  management_ip_configuration {
    name                 = "management_configuration"
    subnet_id            = var.firewall_mgmt_subnet_id
    public_ip_address_id = azurerm_public_ip.fwmgmtpip.id
  }
}

resource "azurerm_firewall_application_rule_collection" "app_rule_collection" {
  name                = "default_collection"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group_name
  priority            = 500
  action              = "Allow"

  rule {
    name = "Allow fqdns"
    source_addresses = var.vm_subnet_cidr  

    target_fqdns = var.allowed_urls
    protocol {
      port = "80"
      type = "Http"
    }

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

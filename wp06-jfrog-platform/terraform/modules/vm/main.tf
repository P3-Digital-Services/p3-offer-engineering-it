resource "azurerm_public_ip" "public_ip" {
  name                = "${var.name}-public-ip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"

  tags = var.tags
}

resource "azurerm_network_interface" "linux_agent_external" {
  name                = "${var.name}-external-nic"
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "external"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "linux_agent" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name
  size                = "standard_d2as_v4"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.linux_agent_external.id
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = var.tags
}

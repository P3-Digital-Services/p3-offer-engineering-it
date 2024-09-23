//// Random password
resource "random_password" "password" {
  length  = 16
  special = true
}

//// NIC
resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_address_id
  }
}

//// NSG NIC association
resource "azurerm_network_interface_security_group_association" "nsg_key" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = var.network_security_group_id
}

//// VM
resource "azurerm_windows_virtual_machine" "vm" {
  location               = var.location
  resource_group_name    = var.resource_group_name
  name                   = var.name
  computer_name          = substr(var.name, 0, 15)
  network_interface_ids  = [azurerm_network_interface.nic.id]
  size                   = var.size
  admin_username         = var.admin_username
  admin_password         = random_password.password.result
  provision_vm_agent     = true
  source_image_id        = var.source_image_id
  identity {
    type                 = "SystemAssigned, UserAssigned"
    identity_ids         = var.identity_ids
  }
  os_disk {
    name                 = "${var.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 128
  }
  boot_diagnostics       {}
  tags                   = var.tags
}
// ----- NETWORK INTERFACE -----
resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id != "" ? var.public_ip_id : null
  }
}

// ----- NETWORK INTERFACE BACKEND POOL ASSOCIATION -----
resource "azurerm_network_interface_backend_address_pool_association" "nic_backend_pool_assoc" {
  count = var.nic_backend_pool_assoc ? 1 : 0

  network_interface_id    = azurerm_network_interface.nic.id
  ip_configuration_name   = azurerm_network_interface.nic.ip_configuration[0].name
  backend_address_pool_id = var.backend_address_pool_id

  depends_on = [
    azurerm_network_interface.nic
  ]
}

// ----- VIRTUAL MACHINE ------
resource "azurerm_linux_virtual_machine" "vm" {
  location            = var.location
  resource_group_name = var.resource_group_name
  // ----- NAMING -----
  name          = var.name
  computer_name = replace(var.name, "-", "")
  // ----- NETWORKING -----
  network_interface_ids = [azurerm_network_interface.nic.id]
  // ----- SKU -----
  size = var.size
  // ----- CREDENTIALS -----
  admin_username = var.admin_username
  admin_password = var.admin_password
  // ----- AVAILABILITY ZONE -----
  zone = var.zone
  // ----- ACCOUNT -----
  disable_password_authentication = false
  // ----- IMAGE -----
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  // ----- OS DISK -----
  os_disk {
    name                 = "${var.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 32
  }
  // ----- BOOT DIAGNOSTICS ----
  boot_diagnostics {}
  tags = var.tags
}

// ----- AZURE MONITOR -----
resource "azurerm_virtual_machine_extension" "AzureMonitorLinuxAgent" {
  name                 = "AzureMonitorLinuxAgent"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.21"
  settings             = <<SETTINGS
    {
      "workspaceId": "${var.log_analytics_workspace}"
    }
  SETTINGS
}

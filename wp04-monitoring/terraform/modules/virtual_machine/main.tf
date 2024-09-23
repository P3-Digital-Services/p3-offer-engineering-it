// ----- NETWORK INTERFACE -----
resource "azurerm_network_interface" "nic" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id[0]
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = var.public_ip_address
  }
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
  // ----- TWEAKS -----
  provision_vm_agent         = true
  allow_extension_operations = true
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
  // ----- IDENTITY -----
  identity {
    type         = "SystemAssigned"
  }
  // ----- OS DISK -----
  os_disk {
    name                 = "${var.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.disk_size_gb
  }
  // ----- BOOT DIAGNOSTICS ----
  boot_diagnostics {}
  tags = var.tags
}

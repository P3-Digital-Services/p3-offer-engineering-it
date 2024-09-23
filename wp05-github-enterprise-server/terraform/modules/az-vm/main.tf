resource "azurerm_public_ip" "pip" {
  count               = var.virtual_machine.is_vm_public ? 1 : 0
  name                = "${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code}-${var.virtual_machine.vm_name}-pip-01"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  tags                = var.project_tag
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code}-${var.virtual_machine.vm_name}-nic-01"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code}-${var.virtual_machine.vm_name}-nic-ip-01"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.virtual_machine.is_vm_public ? azurerm_public_ip.pip[0].id : null
  }
  tags = var.project_tag
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code}-${var.virtual_machine.vm_name}-01"
  location              = var.rg_location
  resource_group_name   = var.rg_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = var.virtual_machine.vm_size

  delete_os_disk_on_termination = var.virtual_machine.is_delete_os_disk_on_termination

  delete_data_disks_on_termination = var.virtual_machine.is_delete_data_disks_on_termination

  storage_image_reference {
    publisher = var.virtual_machine.storage_image_reference.publisher
    offer     = var.virtual_machine.storage_image_reference.offer
    sku       = var.virtual_machine.storage_image_reference.sku
    version   = var.virtual_machine.storage_image_reference.version
  }
  storage_os_disk {
    name              = "${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code}-${var.virtual_machine.vm_name}-os-disk-01"
    caching           = var.virtual_machine.storage_os_disk.caching
    create_option     = var.virtual_machine.storage_os_disk.create_option
    managed_disk_type = var.virtual_machine.storage_os_disk.managed_disk_type
  }
  os_profile {
    computer_name  = var.virtual_machine.is_vm_linux ? "${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code}-${var.virtual_machine.vm_name}-vm-01" : "${var.project_name}${var.location_code}wdvm01"
    admin_username = var.virtual_machine.os_profile.admin_username
    admin_password = var.virtual_machine.os_profile.admin_password
  }
  dynamic "os_profile_linux_config" {
    for_each = var.virtual_machine.is_vm_linux ? [1] : []
    content {
      disable_password_authentication = var.virtual_machine.os_profile_linux_config.disable_password_authentication
    }
  }
  dynamic "os_profile_windows_config" {
    for_each = var.virtual_machine.is_vm_linux ? [] : [1]
    content {
      provision_vm_agent = false
    }
  }
  tags = var.project_tag
}

resource "azurerm_managed_disk" "extra_disk" {
  count                = var.virtual_machine.is_extra_disk ? 1 : 0
  name                 = "${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code}-${var.virtual_machine.vm_name}-exdisk-01"
  location             = var.rg_location
  resource_group_name  = var.rg_name
  storage_account_type = var.virtual_machine.extra_storage_data_disk.exdisk_storage_account_type
  disk_size_gb         = var.virtual_machine.extra_storage_data_disk.exdisk_disk_size_gb
  create_option        = var.virtual_machine.extra_storage_data_disk.exdisk_create_option
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_attach_disk" {
  count              = var.virtual_machine.is_extra_disk ? 1 : 0
  managed_disk_id    = azurerm_managed_disk.extra_disk[0].id
  virtual_machine_id = azurerm_virtual_machine.vm.id
  lun                = "0"
  caching            = var.virtual_machine.extra_storage_data_disk.storage_data_disk_caching
}
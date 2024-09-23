############### General variables ###############
system_code      = "cariad"
environment_code = "dev"
project_tag = {
  ApplicationName = "cariad"
  OwnerService    = "cariad"
  ProjectID       = "cariad-dev"
}
project_name = "wp05"

############### Azure resource in West-US ###############
###### Resource Group Variables ######
location_code_wus2 = "wus2"
az_location_wus2   = "West US 2"

###### Vnet Variables ######
vnet_address_space_wus2 = "10.105.0.0/16"

###### Subnet Variables ######
subnets_wus2 = [
  {
    subnet_name             = "public-subnet",
    subnet_address_prefixes = "10.105.1.0/24",
    is_private_subnet       = true
  },
  {
    subnet_name             = "private-subnet",
    subnet_address_prefixes = "10.105.2.0/24",
    is_private_subnet       = false
  },
]

###### NetWork Security Group Variables ######
network_security_groups_wus2 = [
  {
    nsg_name = "ge-vm",
    security_rules = [
      {
        name                       = "Allow_port_22_Testing",
        priority                   = 100,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "22",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_25_Testing",
        priority                   = 101,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "25",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_80_Testing",
        priority                   = 102,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "80",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_122_Testing",
        priority                   = 103,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "122",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_161_Testing",
        priority                   = 104,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "161",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_443_Testing",
        priority                   = 105,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "443",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_8080_Testing",
        priority                   = 106,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "8080",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_8443_Testing",
        priority                   = 107,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "8443",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_9418_Testing",
        priority                   = 108,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "9418",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_1194_Testing",
        priority                   = 109,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "1194",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      }
    ]
  }
]

virtual_machines_wus2 = [
  {
    vm_name                             = "ge01-vm"
    is_vm_linux                         = true
    is_vm_public                        = true
    subnet_name                         = "public-subnet"
    nsg_name                            = "ge-vm"
    vm_size                             = "Standard_DC4ds_v3"
    is_delete_os_disk_on_termination    = true
    is_delete_data_disks_on_termination = true
    storage_image_reference = {
      publisher = "GitHub"
      offer     = "GitHub-Enterprise"
      sku       = "github-enterprise-gen2"
      version   = "3.14.0"
    }
    storage_os_disk = {
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Premium_LRS"
    }
    os_profile = {
      admin_username = "wp05-admin"
      admin_password = "wp05-admin-@P!"
    }
    os_profile_linux_config = {
      disable_password_authentication = false
    }
    is_extra_disk = true
    extra_storage_data_disk = {
      exdisk_disk_size_gb         = 150
      exdisk_storage_account_type = "Premium_LRS"
      exdisk_create_option        = "Empty"
      storage_data_disk_caching   = "ReadWrite"
    }
  },
  {
    vm_name                             = "ge02-vm"
    is_vm_linux                         = true
    is_vm_public                        = true
    subnet_name                         = "public-subnet"
    nsg_name                            = "ge-vm"
    vm_size                             = "Standard_DC4ds_v3"
    is_delete_os_disk_on_termination    = true
    is_delete_data_disks_on_termination = true
    storage_image_reference = {
      publisher = "GitHub"
      offer     = "GitHub-Enterprise"
      sku       = "github-enterprise-gen2"
      version   = "3.14.0"
    }
    storage_os_disk = {
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Premium_LRS"
    }
    os_profile = {
      admin_username = "wp05-admin"
      admin_password = "wp05-admin-@P!"
    }
    os_profile_linux_config = {
      disable_password_authentication = false
    }
    is_extra_disk = true
    extra_storage_data_disk = {
      exdisk_disk_size_gb         = 150
      exdisk_storage_account_type = "Premium_LRS"
      exdisk_create_option        = "Empty"
      storage_data_disk_caching   = "ReadWrite"
    }
  }
]

############### Azure resource in East-US ###############
###### Resource Group Variables ######
location_code_eus = "eus"
az_location_eus   = "East US"

###### Vnet Variables ######
vnet_address_space_eus = "10.106.0.0/16"

###### Subnet Variables ######
subnets_eus = [
  {
    subnet_name             = "public-subnet",
    subnet_address_prefixes = "10.106.1.0/24",
    is_private_subnet       = true
  },
  {
    subnet_name             = "private-subnet",
    subnet_address_prefixes = "10.106.2.0/24",
    is_private_subnet       = false
  },
]

###### NetWork Security Group Variables ######
network_security_groups_eus = [
  {
    nsg_name = "ge-vm",
    security_rules = [
      {
        name                       = "Allow_port_22_Testing",
        priority                   = 100,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "22",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_25_Testing",
        priority                   = 101,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "25",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_80_Testing",
        priority                   = 102,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "80",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_122_Testing",
        priority                   = 103,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "122",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_161_Testing",
        priority                   = 104,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "161",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_443_Testing",
        priority                   = 105,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "443",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_8080_Testing",
        priority                   = 106,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "8080",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_8443_Testing",
        priority                   = 107,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "8443",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_9418_Testing",
        priority                   = 108,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "9418",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      },
      {
        name                       = "Allow_port_1194_Testing",
        priority                   = 109,
        direction                  = "Inbound",
        access                     = "Allow",
        protocol                   = "Tcp",
        source_port_range          = "*",
        destination_port_range     = "1194",
        source_address_prefix      = "*",
        destination_address_prefix = "*"
      }
    ]
  }
]

###### Virtual Machine Variables ######
virtual_machines_eus = [
  {
    vm_name                             = "ge03-vm"
    is_vm_linux                         = true
    is_vm_public                        = true
    subnet_name                         = "public-subnet"
    nsg_name                            = "ge-vm"
    vm_size                             = "Standard_DC4ds_v3"
    is_delete_os_disk_on_termination    = true
    is_delete_data_disks_on_termination = true
    storage_image_reference = {
      publisher = "GitHub"
      offer     = "GitHub-Enterprise"
      sku       = "github-enterprise-gen2"
      version   = "3.14.0"
    }
    storage_os_disk = {
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Premium_LRS"
    }
    os_profile = {
      admin_username = "wp05-admin"
      admin_password = "wp05-admin-@P!"
    }
    os_profile_linux_config = {
      disable_password_authentication = false
    }
    is_extra_disk = true
    extra_storage_data_disk = {
      exdisk_disk_size_gb         = 150
      exdisk_storage_account_type = "Premium_LRS"
      exdisk_create_option        = "Empty"
      storage_data_disk_caching   = "ReadWrite"
    }
  },
  {
    vm_name                             = "ge04-vm"
    is_vm_linux                         = true
    is_vm_public                        = true
    subnet_name                         = "public-subnet"
    nsg_name                            = "ge-vm"
    vm_size                             = "Standard_DC4ds_v3"
    is_extra_disk                       = false
    is_delete_os_disk_on_termination    = true
    is_delete_data_disks_on_termination = true
    storage_image_reference = {
      publisher = "GitHub"
      offer     = "GitHub-Enterprise"
      sku       = "github-enterprise-gen2"
      version   = "3.14.0"
    }
    storage_os_disk = {
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Premium_LRS"
    }
    os_profile = {
      admin_username = "wp05-admin"
      admin_password = "wp05-admin-@P!"
    }
    os_profile_linux_config = {
      disable_password_authentication = false
    }
    extra_storage_data_disk = {
      exdisk_disk_size_gb         = null
      exdisk_storage_account_type = null
      exdisk_create_option        = null
      storage_data_disk_caching   = null
    }
  }
]

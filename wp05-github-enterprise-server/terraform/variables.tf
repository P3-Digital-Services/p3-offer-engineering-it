############### General variables ###############
variable "system_code" {
  description = "A system code identifies an application."
  type        = string
  default     = "cariad"
}

variable "environment_code" {
  description = "The code of development environment. Supported values include: dev, stg or prod."
  type        = string

  validation {
    condition     = contains(["dev", "test", "poc", "stg", "prod"], var.environment_code)
    error_message = "Argument \"environment_code\" must be either \"dev\", \"test\", \"poc\", \"stg\", or \"prod\"."
  }
}

variable "project_tag" {
  type        = map(string)
  description = "List of the tag of resource"
}

variable "project_name" {
  type        = string
  description = "Project name"
}
############### Azure resource in West-US ###############
###### Resource Group Variables ######
variable "location_code_wus2" {
  type        = string
  description = "Short name of the location"
}

variable "az_location_wus2" {
  type        = string
  description = "Location where the Azure resources are deployed"
}

###### Vnet Variables ######
variable "vnet_address_space_wus2" {
  type        = string
  description = "The IP address space of Vnet"
}

###### Subnet Variables ######
variable "subnets_wus2" {
  type = list(object({
    subnet_name             = string
    subnet_address_prefixes = string
    is_private_subnet       = bool
  }))
  description = "The list of subnet properties being created"
}

###### NetWork Security Group Variables ######
variable "network_security_groups_wus2" {
  type = list(object({
    nsg_name = string
    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
  description = "The security rules of network security group"
}

variable "virtual_machines_wus2" {
  type = list(object({
    vm_name                             = string
    is_vm_linux                         = bool
    is_vm_public                        = bool
    subnet_name                         = string
    nsg_name                            = string
    vm_size                             = string
    is_extra_disk                       = bool
    is_delete_os_disk_on_termination    = bool
    is_delete_data_disks_on_termination = bool
    storage_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    storage_os_disk = object({
      caching           = string
      create_option     = string
      managed_disk_type = string
    })
    os_profile = object({
      admin_username = string
      admin_password = string
    })
    os_profile_linux_config = object({
      disable_password_authentication = bool
    })
    extra_storage_data_disk = object({
      exdisk_disk_size_gb         = number
      exdisk_create_option        = string
      exdisk_storage_account_type = string
      storage_data_disk_caching   = string
    })
  }))
  description = "The properties of Virtual machine will be created"
}

############### Azure resource in East-US ###############
###### Resource Group Variables ######
variable "location_code_eus" {
  type        = string
  description = "Short name of the location"
}

variable "az_location_eus" {
  type        = string
  description = "Location where the Azure resources are deployed"
}

###### Vnet Variables ######
variable "vnet_address_space_eus" {
  type        = string
  description = "The IP address space of Vnet"
}

###### Subnet Variables ######
variable "subnets_eus" {
  type = list(object({
    subnet_name             = string
    subnet_address_prefixes = string
    is_private_subnet       = bool
  }))
  description = "The list of subnet properties being created"
}

###### NetWork Security Group Variables ######
variable "network_security_groups_eus" {
  type = list(object({
    nsg_name = string
    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
  description = "The security rules of network security group"
}

variable "virtual_machines_eus" {
  type = list(object({
    vm_name                             = string
    is_vm_linux                         = bool
    is_vm_public                        = bool
    subnet_name                         = string
    nsg_name                            = string
    vm_size                             = string
    is_extra_disk                       = bool
    is_delete_os_disk_on_termination    = bool
    is_delete_data_disks_on_termination = bool
    storage_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    storage_os_disk = object({
      caching           = string
      create_option     = string
      managed_disk_type = string
    })
    os_profile = object({
      admin_username = string
      admin_password = string
    })
    os_profile_linux_config = object({
      disable_password_authentication = bool
    })
    extra_storage_data_disk = object({
      exdisk_disk_size_gb         = number
      exdisk_create_option        = string
      exdisk_storage_account_type = string
      storage_data_disk_caching   = string
    })
  }))
  description = "The properties of Virtual machine will be created"
}


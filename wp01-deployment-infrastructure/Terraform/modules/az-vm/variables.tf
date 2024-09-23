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

variable "location_code" {
    type = string
    description = "Short name of the location"
}

variable "project_tag" {
    type = map(string)
    description = "List of the tag of resource"
}

variable "project_name" {
    type = string
    description = "Name of the project"
}

############### VM Variables ###############
variable "virtual_machine" {
    type = object({
        vm_name = string
        is_vm_linux = bool
        is_vm_public = bool
        subnet_name = string
        nsg_name = string
        vm_size = string
        is_delete_os_disk_on_termination = bool
        is_delete_data_disks_on_termination = bool
        storage_image_reference = object({
            publisher = string
            offer = string
            sku = string
            version = string
        })
        storage_os_disk = object({
            caching = string
            create_option = string
            managed_disk_type = string
        })
        os_profile = object({
            admin_username = string
            admin_password = string
        })
        os_profile_linux_config = object({
            disable_password_authentication = bool
        })
    })
    description = "The properties of Virtual machine will be created"
}

variable "rg_location" {
    type = string
    description = "Location where the Azure resources are deployed"
}

variable "rg_name" {
    type = string
    description = "Name of the resource group"
}

variable "subnet_id" {
    type = string
    description = "The subnet ID where the VM will be created"
}

variable "nsg_id" {
    type = string
    description = "The network security group ID will be attached to NIC"
}
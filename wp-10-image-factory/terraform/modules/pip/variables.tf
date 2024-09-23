variable "name" {
  description = "The name of the Public IP Address. This name will be used to generate the resource name in Azure."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,80}$", var.name))
    error_message = "The name must be between 1 and 80 characters long and can contain only letters, numbers, hyphens, and underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Public IP Address."
  type        = string
}

variable "location" {
  description = "The Azure region where the Public IP Address should be created."
  type        = string
}

variable "allocation_method" {
  description = "Defines the allocation method for this IP address. Possible values are 'Static' or 'Dynamic'."
  type        = string
  validation {
    condition     = contains(["Static", "Dynamic"], var.allocation_method)
    error_message = "The allocation_method must be either 'Static' or 'Dynamic'."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the Public IP Address resource."
  type        = map(string)
  default     = {}
}
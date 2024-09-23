variable "location" {
  description = "The Azure region where the User Assigned Managed Identity should be created."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.location))
    error_message = "The location must be a valid Azure region name without spaces or special characters."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the User Assigned Managed Identity resource."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "The name of the User Assigned Managed Identity. This name will be used to generate the resource name in Azure."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{3,128}$", var.name))
    error_message = "The name must be between 3 and 128 characters long and can contain only letters, numbers, hyphens, and underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the User Assigned Managed Identity."
  type        = string
}

variable "builder_resource_group_name" {
  description = "The name of the resource group where the virtual machine will be created"
  type        = string
}
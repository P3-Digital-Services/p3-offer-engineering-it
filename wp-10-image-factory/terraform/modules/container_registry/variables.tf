variable "location" {
  description = "The Azure region where the Container Registry should be created."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
}

variable "name" {
  description = "The name of the Container Registry. Must be globally unique, alphanumeric, and between 5-50 characters."
  type        = string
}

variable "sku" {
  description = "The SKU name of the Container Registry. Possible values are Basic, Standard and Premium."
  type        = string
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "The SKU must be one of: Basic, Standard, Premium."
  }
}

variable "admin_enabled" {
  description = "Specifies whether the admin user is enabled for the Container Registry."
  type        = bool
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Container Registry."
  type        = string
}

variable "principal_id" {
  description = "The ID of the Principal (User, Group or Service Principal) to assign the Role Definition to."
  type        = string
}
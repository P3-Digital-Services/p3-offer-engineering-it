variable "location" {
  description = "The Azure region where the Shared Image Gallery should be created."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the Shared Image Gallery resource."
  type        = map(string)
}

variable "name" {
  description = "The name of the Shared Image Gallery. This name will be used to generate the Gallery's resource name."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]([-a-zA-Z0-9]{0,78}[a-zA-Z0-9])?$", var.name))
    error_message = "The gallery name must be between 1 and 80 characters long, and can contain only letters, numbers, and hyphens. It must start and end with a letter or number."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Shared Image Gallery."
  type        = string
}

variable "principal_id" {
  description = "The ID of the Principal (User, Group or Service Principal) to assign RBAC roles for the Shared Image Gallery."
  type        = string
}
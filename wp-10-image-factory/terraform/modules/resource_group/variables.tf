variable "location" {
  description = "The Azure region where the Resource Group should be created."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.location))
    error_message = "The location must be a valid Azure region name without spaces or special characters."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the Resource Group."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "The name of the Resource Group. This name will be used to generate the Resource Group's resource name in Azure."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_()]{1,90}$", var.name))
    error_message = "The name must be between 1 and 90 characters long and can contain only letters, numbers, hyphens, underscores, and parentheses."
  }
}
variable "name" {
  description = "The name of the Data Collection Rule. This name will be used to generate the rule's resource name."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,63}$", var.name))
    error_message = "The name must be between 3 and 63 characters long, and can contain only letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Data Collection Rule."
  type        = string
}

variable "location" {
  description = "The Azure region where the Data Collection Rule should be created."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the Data Collection Rule resource."
  type        = map(string)
}

variable "workspace_resource_id" {
  description = "The resource ID of the Log Analytics workspace where the collected data should be sent."
  type        = string
}
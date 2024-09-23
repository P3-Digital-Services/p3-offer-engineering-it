variable "location" {
  description = "The Azure region where the Network Security Group should be created."
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "A mapping of tags to assign to the Network Security Group resource."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "The name of the Network Security Group. This name will be used to generate the NSG's resource name."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,80}$", var.name))
    error_message = "The name must be between 1 and 80 characters long and can contain only letters, numbers, hyphens, and underscores."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Network Security Group."
  type        = string
}

variable "security_rules" {
  description = "A list of security rules to apply to the Network Security Group. Each rule is an object with properties defining the rule's behavior."
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    description                  = optional(string, null)
    source_port_range            = optional(string, null)
    source_port_ranges           = optional(list(string), [])
    destination_port_range       = optional(string, null)
    destination_port_ranges      = optional(list(string), [])
    source_address_prefix        = optional(string, null)
    source_address_prefixes      = optional(list(string), [])
    destination_address_prefix   = optional(string, null)
    destination_address_prefixes = optional(list(string), [])
  }))
  default = []

}
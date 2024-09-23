variable "location" {
  description = "The location/region where the resource will be deployed."
  default     = "westeurope"
}

variable "tags" {
  description = "A map of tags to be applied to the resource."
  default     = {}
}

variable "name" {
  description = "The name of the resource."
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resource will be created."
}

variable "security_rules" {
  description = "A list of security rules to be applied to the network security group."
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

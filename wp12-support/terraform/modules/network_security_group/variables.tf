variable "location" {
  default = "westeurope"
}
variable "tags" {
  default = {}
}
variable "name" {}
variable "resource_group_name" {}
variable "security_rules" {
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
variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
}

variable "subnet_nsg" {
  description = "The ID of the Network Security Group to associate with the subnet"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
}

variable "delegation" {
  description = "Optional delegation block for the subnet"
  type = object({
    name = string
    service_delegation = object({
      name    = string
      actions = list(string)
    })
  })
  default = null
}

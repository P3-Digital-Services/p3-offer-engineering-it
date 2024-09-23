variable "name" {
  description = "The name of the virtual network"
  type        = string
}

variable "location" {
  description = "The location where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "virtual_address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
}

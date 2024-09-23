variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources."
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine."
  type        = string
}

variable "vm_size" {
  description = "The size of the virtual machine."
  type        = string
}

variable "admin_username" {
  description = "The admin username for the virtual machine."
  type        = string
}

variable "admin_password" {
  description = "The admin password for the virtual machine."
  type        = string
  sensitive   = true
}

variable "image_publisher" {
  description = "The publisher of the image."
  type        = string
}

variable "image_offer" {
  description = "The offer of the image."
  type        = string
}

variable "image_sku" {
  description = "The SKU of the image."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the NIC will be deployed."
  type        = string
}

variable "tags" {
  type = map(string)
}
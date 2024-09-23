variable "name" {
  description = "The name of the Public IP."
  type        = string
}

variable "location" {
  description = "The location of the Public IP."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "allocation_method" {
  description = "The allocation method for the Public IP."
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the resource."
  type        = map(string)
}

variable "sku_tier" {
  description = "The SKU tier for the Public IP."
  type        = string
}

variable "sku" {
  description = "The SKU for the Public IP."
  type        = string
}

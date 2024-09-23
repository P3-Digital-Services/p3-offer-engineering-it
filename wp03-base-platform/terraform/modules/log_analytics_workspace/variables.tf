variable "name" {
  description = "The name of the resource."
}

variable "location" {
  description = "The location/region where the resource will be deployed."
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resource will be created."
}

variable "sku" {
  description = "The SKU (Stock Keeping Unit) for the resource, defining its pricing tier."
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "The number of days to retain data in the resource."
  default     = 30
}

variable "daily_quota_gb" {
  description = "The daily quota in gigabytes for the resource."
  default     = 1
}

variable "tags" {
  description = "A map of tags to be applied to the resource."
  default     = {}
}

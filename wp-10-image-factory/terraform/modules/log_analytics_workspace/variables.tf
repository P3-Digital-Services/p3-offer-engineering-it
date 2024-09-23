variable "name" {
  description = "The name of the Log Analytics Workspace. This name will be used to generate the workspace's resource name."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", var.name))
    error_message = "The workspace name must be between 4 and 63 characters long, and can contain only letters, numbers, and hyphens. It must start and end with a letter or number."
  }
}

variable "location" {
  description = "The Azure region where the Log Analytics Workspace should be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Log Analytics Workspace."
  type        = string
}

variable "sku" {
  description = "Specifies the SKU of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018."
  type        = string
  default     = "PerGB2018"
  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.sku)
    error_message = "The SKU must be one of: Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, or PerGB2018."
  }
}

variable "retention_in_days" {
  description = "The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730."
  type        = number
  default     = 30
  validation {
    condition     = var.retention_in_days == 7 || (var.retention_in_days >= 30 && var.retention_in_days <= 730)
    error_message = "The retention_in_days must be either 7 (Free Tier only) or between 30 and 730."
  }
}

variable "daily_quota_gb" {
  description = "The workspace daily quota for ingestion in GB. Defaults to 1 GB."
  type        = number
  default     = 1
}

variable "tags" {
  description = "A mapping of tags to assign to the Log Analytics Workspace resource."
  type        = map(string)
  default     = {}
}
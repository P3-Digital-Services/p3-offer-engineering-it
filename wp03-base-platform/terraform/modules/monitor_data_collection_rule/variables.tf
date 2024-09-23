variable "name" {
  description = "The name of the resource."
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resource will be created."
}

variable "location" {
  description = "The location/region where the resource will be deployed."
}

variable "tags" {
  description = "A map of tags to be applied to the resource."
}

variable "workspace_resource_id" {
  description = "The resource ID of the Log Analytics workspace."
}

variable "destination" {
  description = "The destination for data collection, such as 'Log-Analytics'."
}

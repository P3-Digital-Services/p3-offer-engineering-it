variable "data_collection_rule_id" {
  description = "The resource ID of the Data Collection Rule to associate with the virtual machine."
  type        = string
  validation {
    condition     = can(regex("^/subscriptions/[a-zA-Z0-9-]+/resourceGroups/[a-zA-Z0-9-]+/providers/Microsoft.Insights/dataCollectionRules/[a-zA-Z0-9-]+$", var.data_collection_rule_id))
    error_message = "The data_collection_rule_id must be a valid Azure resource ID for a Data Collection Rule."
  }
}

variable "vm_id" {
  description = "The resource ID of the Azure virtual machine to associate with the Data Collection Rule."
  type        = string
}

variable "vm_name" {
  description = "The name of the Azure virtual machine. This is used to generate a unique name for the association."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,64}$", var.vm_name))
    error_message = "The vm_name must be between 1 and 64 characters long and can contain only letters, numbers, and hyphens."
  }
}
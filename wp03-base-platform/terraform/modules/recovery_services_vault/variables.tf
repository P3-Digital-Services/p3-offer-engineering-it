variable "name" {
  description = "The name of the Backup Vault."
  type        = string
}

variable "location" {
  description = "The location of the Backup Vault."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
}

variable "vm_ids" {
  description = "A list of VM IDs to be protected."
  type        = list(string)
}

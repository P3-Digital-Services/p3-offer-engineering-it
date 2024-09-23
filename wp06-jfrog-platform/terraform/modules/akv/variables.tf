variable "key_vault_name" {
  description = "The name of the Key Vault"
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group in which to create the Key Vault"
  type        = string
}

variable "location" {
  description = "The location/region where the Key Vault will be created"
  type        = string
}

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID that should be used for this Key Vault"
  type        = string
}

variable "object_id" {
  description = "The object ID of the service principal or user that will be granted access to the Key Vault"
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the Key Vault. Possible values are 'standard' or 'premium'"
  type        = string
  default     = "standard"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
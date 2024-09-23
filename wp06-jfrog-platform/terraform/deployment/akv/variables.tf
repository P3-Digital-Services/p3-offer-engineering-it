variable "name" {
  description = "The name of the Key Vault"
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group in which to create the Key Vault"
  type        = string
}

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID that should be used for this Key Vault"
  type        = string
}

variable "service_principal_name" {
  description = "The name of the service principal that will be granted access to the Key Vault"
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
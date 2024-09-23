variable "client_id" {
  description = "The Client ID of the Service Principal used for accessing Azure resources."
  type        = string
}


variable "client_secret" {
  description = "The Client Secret of the Service Principal used for accessing Azure resources."
  type        = string
}


variable "subscription_id" {
  description = "The ID of the Azure Subscription where the resources will be provisioned."
  type        = string
}


variable "tenant_id" {
  description = "The Azure Active Directory Tenant ID associated with the subscription."
  type        = string
}


variable "admin_username" {
  description = "The administrator username for the virtual machines."
  type        = string
}


variable "admin_password" {
  description = "The administrator password for the virtual machines."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default = {
    project-name = "cariad-monitoring"
    environment  = "demo"
    created-by   = "igor.stefanovic@p3-group.com"
  }
}

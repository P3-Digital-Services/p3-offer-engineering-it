############### General variables ###############
variable "system_code" {
  description = "A system code identifies an application."
  type        = string
  default     = "cariad"
}

variable "environment_code" {
  description = "The code of development environment. Supported values include: dev, stg or prod."
  type        = string

  validation {
    condition     = contains(["dev", "test", "poc", "stg", "prod"], var.environment_code)
    error_message = "Argument \"environment_code\" must be either \"dev\", \"test\", \"poc\", \"stg\", or \"prod\"."
  }
}

variable "project_tag" {
  type        = map(string)
  description = "List of the tag of resource"
}

variable "location_code" {
  type        = string
  description = "Short name of the location"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
}
############### Resource Group Variables ###############
variable "rg_location" {
  type        = string
  description = "Location where the Azure resources are deployed"
}

variable "rg_name" {
  type        = string
  description = "Name of the resource group"
}

variable "network_security_groups" {
  type = list(object({
    nsg_name = string
    security_rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
  description = "The security rules of network security group"
}
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

variable "location_code" {
    type = string
    description = "Short name of the location"
}

variable "project_tag" {
    type = map(string)
    description = "List of the tag of resource"
}

############### Vnet Variables ###############
variable "project_name" {
    type = string
    description = "Name of the project"
}

variable "rg_location" {
    type = string
    description = "Location where the Azure resources are deployed"
}

variable "rg_name" {
    type = string
    description = "Name of the resource group"
}

variable "vnet_address_space" {
    type = string
    description = "The IP address space of Vnet"
}
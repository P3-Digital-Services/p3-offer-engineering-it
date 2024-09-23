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

variable "project_name" {
    type = string
    description = "Name of the Project"
}

############### Subnet Variables ###############
variable "subnets" {
    type = list(object({
      subnet_name = string
      subnet_address_prefixes = string
      is_private_subnet = bool
    }))
    description = "The list of subnet properties being created"
}

variable "rg_name" {
    type = string
    description = "Name of the Project"
}

variable "vnet_name" {
    type = string
    description = "Name of the Project"
}
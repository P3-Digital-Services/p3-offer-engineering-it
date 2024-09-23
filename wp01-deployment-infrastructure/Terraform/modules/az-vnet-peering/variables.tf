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
    description = "Name of the project"
}

############### Vnet Peering Variables ###############
variable "vnet_peering_name" {
    type = string
    description = "Name of the Vnet peering"
}

variable "rg_name" {
    type = string
    description = "Name of the resource group"
}

variable "remote_virtual_network_id" {
    type = string
    description = "Azure resource ID of the remote virtual network"
}

variable "vnet_name" {
    type = string
    description = "The name of the virtual network"
}


variable "is_allow_virtual_network_access" {
    type = bool
    description = "Controls if the traffic from the local virtual network can reach the remote virtual network"
}

variable "is_allow_forwarded_traffic" {
    type = bool
    description = "Controls if forwarded traffic from VMs in the remote virtual network is allowed"
}

variable "is_allow_gateway_transit" {
    type = bool
    description = "Controls gatewayLinks can be used in the remote virtual network’s link to the local virtual network."
}
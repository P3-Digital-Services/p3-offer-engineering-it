variable "name" {
  description = "The name of the firewall"
  type        = string
}

variable "location" {
  description = "The location/region where the firewall will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the firewall"
  type        = string
}

variable "pipname" {
  description = "The name of the public IP address for the firewall"
  type        = string
}

variable "firewall_subnet_id" {
  description = "The ID of the AzureFirewallSubnet"
  type        = string
}

variable "firewall_mgmt_subnet_id" {
  description = "The ID of the AzureFirewallManagementSubnet"
  type        = string
}

variable "vm_subnet_cidr" {
  description = "The CIDR block of the VM subnet"
  type        = list
}

variable "allowed_urls" {
  description = "The list of allowed url's"
  type        = list
}
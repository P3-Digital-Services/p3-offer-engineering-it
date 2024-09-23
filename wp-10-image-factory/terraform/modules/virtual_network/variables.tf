variable "location" {}
variable "tags" {}
variable "name" {}
variable "resource_group_name" {}
variable "virtual_address_space" {}
variable "subnet_name" {}
variable "subnet_cidr" {}
variable "subnet_nsg" {}
variable "firewall_subnet_cidr" {
  description = "The CIDR block for the AzureFirewallSubnet"
  type        = string
}

variable "firewall_mgmt_subnet_cidr" {
  description = "The CIDR block for the AzureFirewallManagementSubnet"
  type        = string
}

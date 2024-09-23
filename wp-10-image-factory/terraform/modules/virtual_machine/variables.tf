variable "name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "location" {
  description = "The Azure region where the virtual machine will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the virtual machine will be created"
  type        = string
}



variable "subnet_id" {
  description = "The ID of the subnet where the virtual machine will be connected"
  type        = string
}

variable "public_ip_address_id" {
  description = "The ID of the public IP address to associate with the virtual machine"
  type        = string
}

variable "size" {
  description = "The size of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "The username of the local administrator account"
  type        = string
}

variable "admin_password" {
  description = "The password of the local administrator account"
  type        = string
  sensitive   = true
}

variable "identity_ids" {
  description = "A list of user assigned identity IDs to be assigned to the VM"
  type        = list(string)
}

variable "tags" {
  description = "A mapping of tags to assign to the virtual machine"
  type        = map(string)
}

variable "runner_token" {
  description = "The token used for setting up the GitHub runner"
  type        = string
  sensitive   = true
}

variable "log_analytics_workspace" {
  description = "The ID of the Log Analytics workspace for the Azure Monitor agent"
  type        = string
}
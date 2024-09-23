variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resource group"
  type        = string
}

variable "name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "size" {
  description = "The size of the virtual machine"
  type        = string
}

variable "zone" {
  description = "The availability zone of the virtual machine"
  type        = string
}

variable "admin_username" {
  description = "The admin username for the virtual machine"
  type        = string
}

variable "admin_password" {
  description = "The admin password for the virtual machine"
  type        = string
}

variable "log_analytics_workspace" {
  description = "The ID of the Log Analytics workspace"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}

variable "public_ip_id" {
  description = "The ID of the public IP to be assigned to the VM"
  type        = string
  default     = ""
}

variable "backend_address_pool_id" {
  description = "The ID of the backend address pool for the NIC"
  type        = string
  default     = null
}

variable "nic_backend_pool_assoc" {
  description = "Flag to determine if NIC backend pool association should be created"
  type        = bool
  default     = false
}
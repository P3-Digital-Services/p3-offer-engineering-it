variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "kubernetes_version" {}


variable "aks_network_profile_plugin" {
  type    = string
  default = "azure"
}

variable "admin_group_object_ids" {
  type = list(string)
}

variable "azure_policy_enabled" {
  type    = bool
  default = true
}

variable "subnet_id" {
  type = string
}



variable "network_policy" {
  type    = string
  default = "azure"
}

variable "service_cidr" {
  type    = string
  default = "11.2.0.0/20"
}

variable "dns_service_ip" {
  type    = string
  default = "11.2.15.10"
}

variable "tags" {
  type = map(string)
}

locals {
  system_node_pool = {
    name            = "system"
    node_count      = 1
    vm_size         = "standard_d2as_v4"
    os_disk_size_gb = 32
  }
  shared_node_pool = {
    name            = "shared"
    node_count      = 3
    min_count       = 1
    max_count       = 5
    vm_size         = "standard_d2as_v4"
    os_disk_size_gb = 32
  }
  os_sku       = "Ubuntu"
  os_disk_type = "Ephemeral"
  dns_prefix   = var.name
}

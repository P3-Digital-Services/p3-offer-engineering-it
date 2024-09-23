variable "name" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}


variable "admin_group_object_ids" {
  type = list(string)
}

variable "virtual_network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

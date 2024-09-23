variable "subnet_name" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_prefixes" {
  type = list(string)
}

locals {
  vm_size = "standard_d2as_v4"
}

variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}
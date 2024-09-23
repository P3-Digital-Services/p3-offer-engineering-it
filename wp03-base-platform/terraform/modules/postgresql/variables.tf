variable "name" {
  description = "The name of the PostgreSQL server."
  type        = string
}

variable "location" {
  description = "The location of the PostgreSQL server."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "psql_admin_username" {
  description = "The administrator username for the PostgreSQL server."
  type        = string
}

variable "psql_admin_password" {
  description = "The administrator password for the PostgreSQL server."
  type        = string
}

variable "vnet_id" {
  description = "The ID of the virtual network."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to attach the PostgreSQL server to."
  type        = string
}

variable "database_name" {
  description = "The name of the database to create."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
}

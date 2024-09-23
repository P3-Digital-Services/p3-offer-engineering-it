variable "client_id" {
  description = "The client ID for authentication with Azure."
}

variable "client_secret" {
  description = "The client secret for authentication with Azure."
}

variable "subscription_id" {
  description = "The subscription ID for your Azure account."
}

variable "tenant_id" {
  description = "The tenant ID for your Azure Active Directory."
}

variable "admin_username" {
  description = "The administrator username for the virtual machines."
}

variable "admin_password" {
  description = "The administrator password for the virtual machines."
}

variable "psql_admin_username" {
  description = "The administrator username for the PostgreSQL database."
}

variable "psql_admin_password" {
  description = "The administrator password for the PostgreSQL database."
}

variable "kc_admin_username" {
  description = "The administrator username for Keycloak."
}

variable "kc_admin_password" {
  description = "The administrator password for Keycloak."
}

variable "kc_version" {
  description = "The version of Keycloak to be installed."
}

variable "java_version" {
  description = "The version of Java to be installed."
}

variable "server_domain" {
  description = "The domain name for the server."
}

variable "keycloak_vms_count" {
  description = "The number of virtual machines for Keycloak."
  default     = 3
}

variable "tags" {
  description = "A map of tags to be applied to resources."
  default = {
    project-name = "cariad-keycloak"
    environment  = "demo"
    owner        = "milan.sisovic@p3-group.com, milos.mancic@p3-group.com"
  }
}

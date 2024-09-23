variable "client_id" {
  description = "The Client ID for the Service Principal used to authenticate with Azure. This is part of the Azure AD application registration."
  type        = string
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal used to authenticate with Azure. This is the secret key associated with the Azure AD application."
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "The ID of the Azure Subscription where resources will be deployed. This uniquely identifies the subscription within Azure."
  type        = string
}

variable "tenant_id" {
  description = "The Tenant ID of the Azure Active Directory instance used for authentication. This is also known as the Directory ID."
  type        = string
}

variable "admin_username" {
  description = "The username for the administrative account on Linux VMs. This will be used for SSH access to the virtual machines."
  type        = string
}

variable "admin_password" {
  description = "The password for the administrative account on Linux VMs. This should be a strong password meeting Azure's complexity requirements for Linux VMs."
  type        = string
  sensitive   = true
}

variable "runner_token" {
  description = "The token used to register and authenticate GitHub Actions self-hosted runners. This token is specific to your GitHub repository or organization."
  type        = string
  sensitive   = true
}
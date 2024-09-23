resource "azurerm_storage_account" "stg" {
  location                          = var.location
  resource_group_name               = var.resource_group_name
  name                              = var.name
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  access_tier                       = var.access_tier
  account_kind                      = var.account_kind
  tags                              = var.tags
  public_network_access_enabled     = true
  infrastructure_encryption_enabled = true
  min_tls_version                   = "TLS1_2"

  azure_files_authentication {
    directory_type = "AADDS"
  }

  share_properties {
    retention_policy {
      days = 30
    }
    smb {
      multichannel_enabled            = true
      versions                        = ["SMB3.1.1"]
      authentication_types            = ["Kerberos", "NTLMv2"]
      kerberos_ticket_encryption_type = ["RC4-HMAC", "AES-256"]
      channel_encryption_type         = ["AES-128-CCM", "AES-128-GCM", "AES-256-GCM"]
    }
  }
}

resource "azurerm_recovery_services_vault" "vault" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags                = var.tags

  soft_delete_enabled = true
}

resource "azurerm_backup_policy_vm" "backup_policy" {
  name                = "${var.name}-policy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }
}

resource "azurerm_backup_protected_vm" "protected_vm" {
  count               = length(var.vm_ids)
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = element(var.vm_ids, count.index)
  backup_policy_id    = azurerm_backup_policy_vm.backup_policy.id
}


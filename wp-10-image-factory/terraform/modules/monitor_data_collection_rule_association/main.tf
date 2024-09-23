resource "azurerm_monitor_data_collection_rule_association" "dcr-association" {
  name                    = "dcr-association-${var.vm_name}"
  data_collection_rule_id = var.data_collection_rule_id
  target_resource_id      = var.vm_id
}

resource "azurerm_monitor_data_collection_rule_association" "dcr-association" {
  count                   = length(var.vm_ids)
  name                    = "dcr-association-${var.vm_names[count.index]}"
  data_collection_rule_id = var.data_collection_rule_id
  target_resource_id      = var.vm_ids[count.index]
}
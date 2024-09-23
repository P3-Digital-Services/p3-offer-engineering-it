resource "azurerm_resource_group" "cariad-rg" {
  name     = "${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code}-rg-01"
  location = var.az_location
  tags     = var.project_tag
}
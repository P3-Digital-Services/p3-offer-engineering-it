provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}
resource "azurerm_resource_group" "WP07_rg" {
  name     = "WP07"
  location = "East US"
  tags = {
    Project_Name = "WP07"
  }
}
output "rg_name" {
  description = "The Resource Group name."
  value       = azurerm_resource_group.WP07_rg.name
}
output "rg_id" {
  description = "The Resource Group name."
  value       = azurerm_resource_group.WP07_rg.id
}
output "rg_region" {
  description = "The Resource Group name."
  value       = azurerm_resource_group.WP07_rg.location
}
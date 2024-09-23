output "vnet_nsg" {
  value       = local.azurerm_nsgs
  description = "The network security group"
}
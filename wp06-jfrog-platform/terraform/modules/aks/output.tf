output "aks_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_resource_group_name" {
  value = azurerm_kubernetes_cluster.aks.resource_group_name
}


output "aks_node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "aks_managed_identity" {
  value = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
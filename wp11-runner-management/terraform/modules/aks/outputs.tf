output "id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "identity_res_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].user_assigned_identity_id
}

output "identity_obj_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "identity_cli_id" {
  value = azurerm_kubernetes_cluster.aks.kubelet_identity[0].client_id
}

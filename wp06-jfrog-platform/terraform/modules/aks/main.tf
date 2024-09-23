resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = local.dns_prefix
  kubernetes_version  = var.kubernetes_version
  default_node_pool {
    name                         = local.system_node_pool.name
    node_count                   = local.system_node_pool.node_count
    vm_size                      = local.system_node_pool.vm_size
    os_disk_size_gb              = local.system_node_pool.os_disk_size_gb
    os_sku                       = local.os_sku
    os_disk_type                 = local.os_disk_type
    orchestrator_version         = var.kubernetes_version
    vnet_subnet_id               = var.subnet_id
    only_critical_addons_enabled = true
    node_labels = {
      "role" = "system"
    }
    temporary_name_for_rotation = "temppool"
  }

  identity {
    type = "SystemAssigned"
  }
  local_account_disabled = false
  # RBAC and Azure AD Integration Block
  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = false
    admin_group_object_ids = var.admin_group_object_ids
  }

  # Add on
  azure_policy_enabled = var.azure_policy_enabled

  network_profile {
    network_plugin = var.aks_network_profile_plugin
    network_policy = var.network_policy
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }

  tags = var.tags

}

resource "azurerm_kubernetes_cluster_node_pool" "shared" {
  name                  = local.shared_node_pool.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = local.shared_node_pool.vm_size
  node_count            = local.shared_node_pool.node_count
  os_disk_size_gb       = local.system_node_pool.os_disk_size_gb
  os_sku                = local.os_sku
  os_disk_type          = local.os_disk_type
  orchestrator_version  = var.kubernetes_version
  vnet_subnet_id        = var.subnet_id
  node_labels = {
    "role" = "shared"
  }
  tags = var.tags
}

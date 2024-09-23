resource "azurerm_kubernetes_cluster" "aks" {
  name                             = var.name
  location                         = var.location
  resource_group_name              = var.resource_group_name
  dns_prefix                       = var.name
  kubernetes_version               = var.kubernetes_version
  private_cluster_enabled          = var.private_cluster_enabled
  http_application_routing_enabled = var.http_application_routing_enabled
  azure_policy_enabled             = var.azure_policy_enabled
  tags                             = var.tags
  identity {
    type                 = var.identity.type
  }
  default_node_pool {
    name                 = var.default_node_pool.name
    type                 = var.default_node_pool.type
    node_count           = var.default_node_pool.node_count
    vm_size              = var.default_node_pool.vm_size
    max_pods             = var.default_node_pool.max_pods
    fips_enabled         = var.default_node_pool.fips_enabled
    orchestrator_version = var.default_node_pool.orchestrator_version
    os_disk_size_gb      = var.default_node_pool.os_disk_size_gb
    os_disk_type         = var.default_node_pool.os_disk_type
    os_sku               = var.default_node_pool.os_sku
    vnet_subnet_id       = var.default_node_pool.vnet_subnet_id[0]
    zones                = var.default_node_pool.zones
  }
  network_profile {
    network_plugin     = var.network_profile.network_plugin
    load_balancer_sku  = var.network_profile.load_balancer_sku
    service_cidr       = var.network_profile.service_cidr
    dns_service_ip     = var.network_profile.dns_service_ip
    docker_bridge_cidr = var.network_profile.docker_bridge_cidr
  }
}

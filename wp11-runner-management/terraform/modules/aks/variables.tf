variable "name" {}
variable "location" {}
variable "resource_group_name" {}
variable "kubernetes_version" {}
variable "private_cluster_enabled" {}
variable "http_application_routing_enabled" {}
variable "azure_policy_enabled" {}
variable "tags" {}
variable "identity" {
  type = object({
    type         = string
  })   
}
variable "default_node_pool" {
  type = object({
    name                 = string
    type                 = string
    node_count           = number
    vm_size              = string
    max_pods             = number
    fips_enabled         = bool
    orchestrator_version = string
    os_disk_size_gb      = number
    os_disk_type         = string
    os_sku               = string
    vnet_subnet_id       = list(string)
    zones                = list(string)
  })
}
variable "network_profile" {
  type = object({
    network_plugin     = string
    load_balancer_sku  = string
    service_cidr       = string
    dns_service_ip     = string
    docker_bridge_cidr = string
  })
}

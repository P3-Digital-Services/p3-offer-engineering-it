module "az_rg" {
  source = "../modules/az-resource/resoureGroup-network"
}
provider "azurerm" {
  subscription_id = module.az_rg.subcription_id
  features {}
}
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "wp07-aks-dev-cluster01"
  location            = module.az_rg.rg_region
  resource_group_name = module.az_rg.rg_name
  dns_prefix          = "wp07devaks1"

  default_node_pool {
    name       = "wp07nodepool"
    node_count = 3
    vm_size    = "Standard_B2s"
    vnet_subnet_id = module.az_rg.subnet01
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ApplicationName = "AKS-Jenkins"
    OwnerService = "LinhNMD"
    ProjectID = "WB07"
  }
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "wp07storageaccount"
  resource_group_name      = module.az_rg.rg_name
  location                 = module.az_rg.rg_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled = true
  nfsv3_enabled = true
  network_rules {
    default_action = "Deny"
    bypass = ["Logging", "Metrics", "AzureServices"]
    ip_rules = ["0.0.0.0/0"]
  }
  tags = {
    ApplicationName = "AKS-Jenkins"
    OwnerService = "LinhNMD"
    ProjectID = "WB07"
  }
}

resource "azurerm_storage_container" "container_storage" {
  name                  = "wp07storagecontainer"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "container"
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_admin_config_raw
  sensitive = true
}
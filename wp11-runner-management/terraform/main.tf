//// RG
///// In case RG already doesn't exist for Packer.
module "rg" {
  source              = "./modules/rg"
  name                = "testttttt"
  location            = local.resource_group.location
  tags                = local.tags
}

//// NSG
module "nsg" {
  source              = "./modules/nsg"
  resource_group_name = local.resource_group.name
  location            = local.resource_group.location
  name                = "${local.tags.ProjectName}-${local.tags.Environment}-nsg"
  security_rules = [
    {
      name                       = "AllowWinRMHTTP"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5985"
      //// Add more IPs here
      source_address_prefixes    = [
        "0.0.0.0/0"
      ]
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowWinRMHTTPS"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5986"
      source_address_prefixes    = [
        //// Add more IPs here
        "0.0.0.0/0"
      ]
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowRDP"
      priority                   = 102
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefixes    = [
        //// Add more IPs here
        "0.0.0.0/0"
      ]
      destination_address_prefix = "*"
    }
  ]
  tags = local.tags
}

//// VNET
module "vnet" {
  source                = "./modules/vnet"
  resource_group_name   = local.resource_group.name
  location              = local.resource_group.location
  name                  = "${local.tags.ProjectName}-${local.tags.Environment}-vnet"
  virtual_address_space = ["10.0.0.0/16"]
  subnet_name           = "${local.tags.ProjectName}-${local.tags.Environment}-sub"
  subnet_cidr           = "10.0.1.0/24"
  subnet_nsg            = module.nsg.id
  tags                  = local.tags
}

//// UAI
locals {
  uais = toset([ "vm-uai" ])
}

module "uai" {
  for_each            = local.uais
  source              = "./modules/uai"
  resource_group_name = local.resource_group.name
  location            = local.resource_group.location
  name                = "${local.tags.ProjectName}-${local.tags.Environment}-${each.value}"
  tags                = local.tags
}

//// PIP
module "pip" {
  source              = "./modules/pip"
  resource_group_name = local.resource_group.name
  location            = local.resource_group.location
  name                = "${local.tags.ProjectName}-${local.tags.Environment}-pip"
  tags                = local.tags
  allocation_method   = "Dynamic"
}

//// VM
module "vm" {
  source                    = "./modules/vm"
  resource_group_name       = local.resource_group.name
  location                  = local.resource_group.location
  name                      = "${local.tags.ProjectName}-${local.tags.Environment}-vm"
  size                      = "Standard_D2s_v3"
  admin_username            = "vmadmin"
  subnet_id                 = module.vnet.subnet_id
  identity_ids              = [module.uai["vm-uai"].id]
  source_image_id           = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${local.resource_group.name}/providers/Microsoft.Compute/images/cariad-runner-management-demo-img"
  tags                      = local.tags
  public_ip_address_id      = module.pip.id
  network_security_group_id = module.nsg.id
}

//// AKS
module "aks" {
  source                           = "./modules/aks"
  resource_group_name              = local.resource_group.name
  location                         = local.resource_group.location
  name                             = "${local.tags.ProjectName}-${local.tags.Environment}-aks"
  kubernetes_version               = "1.29"
  private_cluster_enabled          = false
  http_application_routing_enabled = false
  azure_policy_enabled             = false
  tags                             = local.tags
  identity                         = { type = "SystemAssigned" }
  default_node_pool                = {
    name                 = "linuxpool"
    type                 = "VirtualMachineScaleSets"
    node_count           = 1
    vm_size              = "Standard_B2s"
    max_pods             = 50
    fips_enabled         = false
    orchestrator_version = "1.29"
    os_disk_size_gb      = 256
    os_disk_type         = "Managed"
    os_sku               = "Ubuntu"
    vnet_subnet_id       = module.vnet.subnet_id
    zones                = [ "1", "2", "3" ]
  }
  network_profile                  = {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
    service_cidr       = "10.1.0.0/16"
    dns_service_ip     = "10.1.0.10"
    docker_bridge_cidr = "10.2.0.1/16"
  }
}

//// ACR
module "acr" {
  source              = "./modules/acr"
  name                = replace("${local.tags.ProjectName}-${local.tags.Environment}-acr","-","")
  resource_group_name = local.resource_group.name
  location            = local.resource_group.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = local.tags
}

//// Role assignments
module "role_assignment" {
//// AcrPull for Containers inside AKS
  source               = "./modules/role_assignment"
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.identity_obj_id
}

output "public_ip" {
  value = module.pip.ip_address
}

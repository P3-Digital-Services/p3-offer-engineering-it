// =================== CARIAD MONITORING DEMO MAIN =================== 

// ----- RESOURCE GROUP -----
module "resource_group" {
  source   = "../modules/resource_group"
  location = "westeurope"
  name     = "rg-${local.tags.project-name}-${local.tags.environment}"
  tags     = local.tags
}

// Image builder rg
module "builder_resource_group" {
  source   = "../modules/resource_group"
  location = "westeurope"
  name     = "rg-cariad-build-vm-image-demo"
  tags     = local.tags
}

// ----- USER ASSIGNED MANAGED IDENTITY -----
module "user_assigned_identity" {
  source              = "../modules/user_assigned_identity"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "id-${local.tags.project-name}-${local.tags.environment}"
  tags                = local.tags
  builder_resource_group_name = module.builder_resource_group.name
  depends_on = [ module.builder_resource_group ]
}

// ----- NETWORK SECURITY GROUP -----
module "network_security_group" {
  source              = "../modules/network_security_group"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "nsg-${local.tags.project-name}-${local.tags.environment}"
  security_rules = [
    {
      name                       = "AllowSSH"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "178.220.230.195"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowSSHAll"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
  tags = local.tags
}

// ----- VIRTUAL NETWORK -----
module "virtual_network" {
  source                    = "../modules/virtual_network"
  name                      = "vnet-${local.tags.project-name}-${local.tags.environment}"
  resource_group_name       = module.resource_group.name
  location                  = module.resource_group.location
  virtual_address_space     = ["10.0.0.0/16"]
  subnet_name               = "subnet-${local.tags.project-name}-${local.tags.environment}"
  subnet_cidr               = "10.0.1.0/24"
  subnet_nsg                = module.network_security_group.id
  firewall_subnet_cidr      = "10.0.2.0/24"
  firewall_mgmt_subnet_cidr = "10.0.3.0/24"
  tags                      = local.tags
}

// ----- PIP -----
module "pip" {
  source              = "../modules/pip"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "pip-${local.tags.project-name}-${local.tags.environment}"
  tags                = local.tags
  allocation_method   = "Dynamic"
}

module "firewall" {
  source                  = "../modules/firewall"
  name                    = "fw-${local.tags.project-name}-${local.tags.environment}"
  resource_group_name     = module.resource_group.name
  location                = module.resource_group.location
  pipname                 = "pip-fw-${local.tags.project-name}-${local.tags.environment}"
  firewall_subnet_id      = module.virtual_network.firewall_subnet_id
  firewall_mgmt_subnet_id = module.virtual_network.firewall_mgmt_subnet_id
  vm_subnet_cidr          = ["10.0.1.0/24"]
  allowed_urls = [
    "*.microsoft.com",
    "*.github.com",
    "github.com",
    "*.githubusercontent.com",
    "*.gitlab.com",
    "*.azure.com",
    "*.windows.net",
    "*.azureedge.net",
    "*.microsoftonline.com",
    "*.login.microsoftonline.com",
    "*.blob.core.windows.net",
    "${module.container_registry.name}.azurecr.io", # Azure Container Registry
    "*.docker.com",
    "*.docker.io",
    "*.quay.io",
    "*.archive.ubuntu.com",
    "*.security.ubuntu.com",
    "*.pypi.org",
    "*.pypi.io",
    "*.npmjs.com",
    "*.rubygems.org",
    "*.packages.microsoft.com",
    "*.nuget.org",
    "aka.ms",
    "ghcr.io",
    "*.anchore.io",
    "anchore.io"
  ]
}

module "routing_table" {
  source              = "../modules/routing_table"
  name                = "rt-${local.tags.project-name}-${local.tags.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  firewall_private_ip = module.firewall.firewall_private_ip
  subnet_id           = module.virtual_network.subnet_id
}

// ----- VIRTUAL MACHINES -----
module "virtual_machine" {
  source              = "../modules/virtual_machine"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "GithubRunner"
  size                = "Standard_B2s"
  //zone                    = 1
  admin_username          = var.admin_username
  admin_password          = var.admin_password
  log_analytics_workspace = module.log_analytics_workspace.id
  subnet_id               = module.virtual_network.subnet_id
  identity_ids            = [module.user_assigned_identity.id]
  tags                    = local.tags
  public_ip_address_id    = module.pip.id
  runner_token            = var.runner_token
}

// ----- DATA COLLETION RULE -----
module "monitor_data_collection_rule" {
  source                = "../modules/monitor_data_collection_rule"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  name                  = "${local.tags.project-name}-${local.tags.environment}"
  workspace_resource_id = module.log_analytics_workspace.id
  tags                  = local.tags
}

// ----- DCR ASSOCIATION -----
module "monitor_data_collection_rule_association" {
  source                  = "../modules/monitor_data_collection_rule_association"
  vm_name                 = module.virtual_machine.name
  vm_id                   = module.virtual_machine.id
  data_collection_rule_id = module.monitor_data_collection_rule.id
}

// ----- LOG ANALYTICS WORKSPACE -----
module "log_analytics_workspace" {
  source              = "../modules/log_analytics_workspace"
  name                = "log-${local.tags.project-name}-${local.tags.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  daily_quota_gb      = 1
  retention_in_days   = 30
  sku                 = "PerGB2018"
  tags                = local.tags
}

module "image_gallery" {
  source              = "../modules/image_gallery"
  name                = replace("ig-${local.tags.project-name}-${local.tags.environment}", "-", "")
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
  principal_id        = module.virtual_machine.identity_principal_id
}

module "container_registry" {
  source              = "../modules/container_registry"
  name                = replace("acr-${local.tags.project-name}-${local.tags.environment}", "-", "")
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
  sku                 = "Standard"
  admin_enabled       = true
  principal_id        = module.user_assigned_identity.principal_id
}

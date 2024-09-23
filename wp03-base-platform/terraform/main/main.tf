// =================== CARIAD KEYCLOAK DEMO ===================

// ----- RESOURCE GROUP -----
module "resource_group" {
  source   = "../modules/resource_group"
  location = "swedencentral"
  name     = "rg-cariad-WP03-Base-Platform"
  tags     = var.tags
}

// ----- NETWORK SECURITY GROUP -----
module "network_security_group" {
  source              = "../modules/network_security_group"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "nsg-${var.tags.project-name}-${var.tags.environment}"
  security_rules = [
    {
      name                       = "AllowSSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTP"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTPS"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
  tags = var.tags
}

// ----- NETWORK SECURITY GROUP FOR POSTGRESQL -----
module "psql_network_security_group" {
  source              = "../modules/network_security_group"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "psql-nsg-${var.tags.project-name}-${var.tags.environment}"
  security_rules = [
    {
      name                       = "AllowPostgreSQLInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5432"
      source_address_prefix      = "10.0.0.0/16"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowPostgreSQLOutbound"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5432"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowPostgreSQLOutboundHA"
      priority                   = 300
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "6432"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
  tags = var.tags
}

// ----- VIRTUAL NETWORK -----
module "virtual_network" {
  source                = "../modules/virtual_network"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  name                  = "vnet-${var.tags.project-name}-${var.tags.environment}"
  virtual_address_space = ["10.0.0.0/16"]
  tags                  = var.tags

  depends_on = [
    module.network_security_group
  ]
}

// ----- DB SUBNET -----
module "default_subnet" {
  source                = "../modules/subnet"
  resource_group_name   = module.resource_group.name
  virtual_network_name  = module.virtual_network.name
  subnet_name           = "default-subnet-${var.tags.project-name}-${var.tags.environment}"
  subnet_cidr           = "10.0.1.0/24"
  subnet_nsg            = module.network_security_group.id
  tags                  = var.tags

  depends_on = [
    module.virtual_network,
    module.network_security_group
  ]
}

// ----- DB SUBNET -----
module "db_subnet" {
  source                = "../modules/subnet"
  resource_group_name   = module.resource_group.name
  virtual_network_name  = module.virtual_network.name
  subnet_name           = "db-subnet-${var.tags.project-name}-${var.tags.environment}"
  subnet_cidr           = "10.0.2.0/24"
  subnet_nsg            = module.psql_network_security_group.id
  delegation            = {
                          name = "postgresql-delegation"
                          service_delegation = {
                            name    = "Microsoft.DBforPostgreSQL/flexibleServers"
                            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
                        }
  }
  tags                  = var.tags

  depends_on = [
    module.virtual_network,
    module.network_security_group
  ]
}

// ----- VIRTUAL MACHINES -----
module "virtual_machine" {
  source                  = "../modules/virtual_machine"
  count                   = var.keycloak_vms_count
  resource_group_name     = module.resource_group.name
  location                = module.resource_group.location
  name                    = "vm${count.index + 1}-${var.tags.project-name}-${var.tags.environment}"
  size                    = "Standard_B1ms"
  zone                    = count.index % 3 + 1
  admin_username          = var.admin_username
  admin_password          = var.admin_password
  log_analytics_workspace = module.log_analytics_workspace.id
  subnet_id               = module.default_subnet.subnet_id
  public_ip_id            = module.public_ip_vm[count.index].public_ip_id
  tags                    = var.tags

  depends_on = [
    module.virtual_network,
    module.default_subnet,
    module.public_ip_vm
  ]
}

// ----- VIRTUAL MACHINE WEBAPP -----
module "virtual_machine_webapp" {
  source                  = "../modules/virtual_machine"
  resource_group_name     = module.resource_group.name
  location                = module.resource_group.location
  name                    = "vm-webapp-${var.tags.project-name}-${var.tags.environment}"
  size                    = "Standard_B1ms"
  zone                    = "1"
  admin_username          = var.admin_username
  admin_password          = var.admin_password
  log_analytics_workspace = module.log_analytics_workspace.id
  subnet_id               = module.default_subnet.subnet_id
  public_ip_id            = module.public_ip_webapp.public_ip_id
  tags                    = var.tags

  depends_on = [
    module.virtual_network,
    module.public_ip_webapp
  ]
}

// ----- DATA COLLETION RULE -----
module "monitor_data_collection_rule" {
  source                = "../modules/monitor_data_collection_rule"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  name                  = "${var.tags.project-name}-${var.tags.environment}"
  workspace_resource_id = module.log_analytics_workspace.id
  destination           = "Log-Analytics"
  tags                  = var.tags
}

// ----- DCR ASSOCIATION -----
module "monitor_data_collection_rule_association" {
  source                  = "../modules/monitor_data_collection_rule_association"
  vm_names                = [for vm in module.virtual_machine : vm.name]
  vm_ids                  = [for vm in module.virtual_machine : vm.id]
  data_collection_rule_id = module.monitor_data_collection_rule.id
}

// ----- LOG ANALYTICS WORKSPACE -----
module "log_analytics_workspace" {
  source              = "../modules/log_analytics_workspace"
  name                = "log-${var.tags.project-name}-${var.tags.environment}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  daily_quota_gb      = 1
  retention_in_days   = 30
  sku                 = "PerGB2018"
  tags                = var.tags
}

// ----- PUBLIC IP FOR WEBAPP MACHINE -----
module "public_ip_webapp" {
  source              = "../modules/public_ip"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "pip-webapp-${var.tags.project-name}-${var.tags.environment}"
  allocation_method   = "Static"
  tags                = var.tags
  sku                 = "Standard"
  sku_tier            = "Regional"
}

// ----- PUBLIC IP FOR VMs -----
module "public_ip_vm" {
  source              = "../modules/public_ip"
  count               = var.keycloak_vms_count
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "pip-vm${count.index + 1}-${var.tags.project-name}-${var.tags.environment}"
  allocation_method   = "Static"
  tags                = var.tags
  sku                 = "Standard"
  sku_tier            = "Regional"
}

// ----- POSTGRESQL FLEXIBLE SERVER -----
module "postgresql" {
  source              = "../modules/postgresql"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "psqlsrv-${var.tags.project-name}-${var.tags.environment}"
  psql_admin_username = var.psql_admin_username
  psql_admin_password = var.psql_admin_password
  vnet_id             = module.virtual_network.id
  subnet_id           = module.db_subnet.subnet_id
  database_name       = "cariad_keycloak"
  tags                = var.tags

  depends_on = [
    module.virtual_network,
    module.db_subnet
  ]
}

// ----- RECOVERY SERVICES VAULT -----
module "backup_services_vault" {
  source              = "../modules/recovery_services_vault"
  name                = "rsv-${var.tags.project-name}-${var.tags.environment}"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  tags                = var.tags
  vm_ids              = concat(
                          [for vm in module.virtual_machine : vm.id],
                          [module.virtual_machine_webapp.id]
                        )
  depends_on = [
    module.virtual_machine,
    module.virtual_machine_webapp
  ]
}

output "webapp_public_ip" {
  value = module.virtual_machine_webapp.public_ip_address
}

output "keycloak_public_ips" {
  value = [for vm in module.virtual_machine : vm.public_ip_address]
}


output "keycloak_private_ips" {
  value = [for vm in module.virtual_machine : vm.private_ip_address]
}

resource "null_resource" "ansible_playbook" {
  provisioner "local-exec" {
    command = <<EOT
      echo "[webapp_vm]" > ../../ansible/inventory.ini
      echo "${module.virtual_machine_webapp.public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      echo "[keycloak_vms]" >> ../../ansible/inventory.ini
      for ip in ${join(" ", module.virtual_machine[*].public_ip_address)}; do
        echo "$ip ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      done
      export KEYCLOAK_PRIVATE_IPS=${join(",", module.virtual_machine[*].private_ip_address)}
      export SERVER_DOMAIN=${var.server_domain}
      export KEYCLOAK_ADMIN_USERNAME=${var.kc_admin_username}
      export KEYCLOAK_ADMIN_PASSWORD=${var.kc_admin_password}
      export KC_DB_URL=${module.postgresql.db_url}
      export KC_DB_NAME=${module.postgresql.db_name}
      export KC_DB_USERNAME=${var.psql_admin_username}
      export KC_DB_PASSWORD=${var.psql_admin_password}
      export JAVA_VERSION=${var.java_version}
      export KC_VERSION=${var.kc_version}
      ansible-playbook -i ../../ansible/inventory.ini ../../ansible/main.yaml
      rm ../../ansible/inventory.ini
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [module.virtual_machine, module.virtual_machine_webapp]
}

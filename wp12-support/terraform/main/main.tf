// =================== CARIAD MONITORING DEMO MAIN =================== 

// ----- RESOURCE GROUP -----
module "resource_group" {
  source   = "../modules/resource_group"
  location = "westeurope"
  name     = "rg-${var.tags.project-name}-${var.tags.environment}"
  tags     = var.tags
}

// ----- PUBLIC IP -----
module "public_ip" {
  source              = "../modules/public_ip"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = "vm-${var.tags.project-name}-${var.tags.environment}-pip"
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
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
      name                       = "AllowGithuB"
      priority                   = 130
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3000"
      source_address_prefixes      = ["192.30.252.0/22", "185.199.108.0/22", "140.82.112.0/20", "143.55.64.0/20"]
      destination_address_prefix = "*"
    },
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
  subnet_name           = "subnet-${var.tags.project-name}-${var.tags.environment}"
  subnet_cidr           = "10.0.1.0/24"
  subnet_nsg            = module.network_security_group.id
  tags                  = var.tags
}

// ----- VIRTUAL MACHINES -----
module "virtual_machine" {
  source               = "../modules/virtual_machine"
  resource_group_name  = module.resource_group.name
  location             = module.resource_group.location
  name                 = "vm-${var.tags.project-name}-${var.tags.environment}" 
  size                 = "Standard_B2s"
  disk_size_gb         = 128
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  subnet_id            = module.virtual_network.subnet_id
  private_ip_address   = "10.0.1.200"
  public_ip_address_id = module.public_ip.id
  tags                 = var.tags
}

// ----- ANSIBLE -----
resource "null_resource" "ansible_playbook" {
  count = 1
  provisioner "local-exec" {
    command = <<EOT
      echo "[server_vm]" > ../../ansible/inventory.ini
      echo "${module.virtual_machine.public_ip_address_id} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      export ZENDESK_SUBDOMAIN=${var.zendesk_subdomain}
      export ZENDESK_EMAIL=${var.zendesk_email}
      export ZENDESK_API_TOKEN=${var.zendesk_api_token}
      export ZENDESK_GROUP=${var.zendesk_group}
      export ANSIBLE_USER=${var.admin_username}
      export ANSIBLE_PASSWORD=${var.admin_password}
      export GROUP_ID_SLACK=${var.group_id_slack}
      export SLACK_BOT_TOKEN=${var.slack_bot_token}
      export SLACK_APP_TOKEN=${var.slack_app_token}
      export JIRA_API_TOKEN=${var.jira_api_token}
      export JIRA_EMAIL=${var.jira_email}
      export JIRA_SEARCH_URL=${var.jira_search_url}
      export JIRA_STATUS_FIELD_ID=${var.jira_status_field_id}
      export JIRA_ISSUE_KEY_FIELD_ID=${var.jira_issue_key_field_id}
      export ZENDESK_TICKET_URL=${var.zendesk_ticket_url}
      export ZENDESK_SEARCH_URL=${var.zendesk_search_url}

      ansible-playbook -i ../../ansible/inventory.ini ../../ansible/main.yml
      rm ../../ansible/inventory.ini
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [module.virtual_machine]
}

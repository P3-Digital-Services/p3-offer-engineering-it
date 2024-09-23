// =================== CARIAD MONITORING DEMO MAIN =================== 

// ----- RESOURCE GROUP -----
module "resource_group" {
  source   = "../modules/resource_group"
  location = "swedencentral"
  name     = "WP04-rg-${var.tags.project-name}-${var.tags.environment}"
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
      name                       = "AllowGrafana"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3000"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTP"
      priority                   = 120
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
      priority                   = 130
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
  count                = 7
  resource_group_name  = module.resource_group.name
  location             = module.resource_group.location
  name                 = count.index == 6 ? "vm-grafana-${var.tags.project-name}-${var.tags.environment}" : "vm${count.index + 1}-${var.tags.project-name}-${var.tags.environment}"
  size                 = "Standard_B2s"
  disk_size_gb         = count.index == 6 ? 256 : 64
  zone                 = count.index % 3 + 1
  admin_username       = var.admin_username
  admin_password       = var.admin_password
  subnet_id            = module.virtual_network.subnet_id
  private_ip_address   = count.index == 6 ? "10.0.1.100" : "10.0.1.${count.index + 11}"
  public_ip_address    = module.public_ip[count.index].id
  tags                 = var.tags
}

// ----- PUBLIC IP -----
module "public_ip" {
  source              = "../modules/public_ip"
  for_each            = { for i in range(7) : i => i == 6 ? "vm-grafana-${var.tags.project-name}-${var.tags.environment}-pip" : "vm${i + 1}-${var.tags.project-name}-${var.tags.environment}-pip" }
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  name                = each.value
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [each.key % 3 + 1]
  tags                = var.tags
}

// ----- ANSIBLE -----
resource "null_resource" "ansible_playbook" {
  count = 1
  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for VMs..."
      sleep 30
      ansible-galaxy collection install community.grafana community.general
      GRAFANA_VM_IP=${module.virtual_machine[6].public_ip_address}
      echo "[server_vms]" > ../../ansible/inventory.ini
      echo "${module.virtual_machine[6].public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      echo "[node_vms]" >> ../../ansible/inventory.ini
      echo "${module.virtual_machine[0].public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      echo "${module.virtual_machine[1].public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      echo "${module.virtual_machine[2].public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      echo "${module.virtual_machine[3].public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      echo "${module.virtual_machine[4].public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      echo "${module.virtual_machine[5].public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      echo "[appserver]" >> ../../ansible/inventory.ini
      echo "${module.virtual_machine[0].public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      echo "${module.virtual_machine[1].public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      echo "${module.virtual_machine[2].public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      echo "${module.virtual_machine[3].public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      echo "${module.virtual_machine[4].public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      echo "[appserver_ssl_expiry]" >> ../../ansible/inventory.ini
      echo "${module.virtual_machine[5].public_ip_address} ansible_user=${var.admin_username} ansible_password=${var.admin_password} ansible_connection=ssh ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ../../ansible/inventory.ini
      ansible-playbook -i ../../ansible/inventory.ini ../../ansible/main.yml \
        -e "PUBLIC_IP_VM1=${module.virtual_machine[0].public_ip_address}" \
        -e "PUBLIC_IP_VM2=${module.virtual_machine[1].public_ip_address}" \
        -e "PUBLIC_IP_VM3=${module.virtual_machine[2].public_ip_address}" \
        -e "PUBLIC_IP_VM4=${module.virtual_machine[3].public_ip_address}" \
        -e "PUBLIC_IP_VM5=${module.virtual_machine[4].public_ip_address}" \
        -e "PUBLIC_IP_VM6=${module.virtual_machine[5].public_ip_address}" \
        -e "PRIVATE_IP_VM1=${module.virtual_machine[0].private_ip_address}" \
        -e "PRIVATE_IP_VM2=${module.virtual_machine[1].private_ip_address}" \
        -e "PRIVATE_IP_VM3=${module.virtual_machine[2].private_ip_address}" \
        -e "PRIVATE_IP_VM4=${module.virtual_machine[3].private_ip_address}" \
        -e "PRIVATE_IP_VM5=${module.virtual_machine[4].private_ip_address}" \
        -e "PRIVATE_IP_VM6=${module.virtual_machine[5].private_ip_address}" \
        -e "PRIVATE_IP_VM7=${module.virtual_machine[6].private_ip_address}" \
        -e "GRAFANA_USER=${var.admin_username}" \
        -e "GRAFANA_PASSWORD=${var.admin_password}"
        echo To access Grafana go to: https://$GRAFANA_VM_IP:3000
      rm ../../ansible/inventory.ini
    EOT
  }
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [module.virtual_machine]
}

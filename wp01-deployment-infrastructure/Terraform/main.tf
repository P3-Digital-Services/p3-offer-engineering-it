############### Azure resource in West-US ###############
module "rg_wus2" {
    source = "./modules/az-resource-group"
    az_location = var.az_location_wus2

    # General variables
    system_code = var.system_code
    environment_code = var.environment_code
    location_code = var.location_code_wus2
    project_name = var.project_name
    project_tag = var.project_tag
}

module "vnet_wus2" {
    source = "./modules/az-vnet"
    rg_location = module.rg_wus2.rg_location
    rg_name = module.rg_wus2.rg_name
    vnet_address_space = var.vnet_address_space_wus2
    
    # General variables
    system_code = var.system_code
    environment_code = var.environment_code
    location_code = var.location_code_wus2
    project_name = var.project_name
    project_tag = var.project_tag
}

module "subnet_wus2" {
    source = "./modules/az-vnet-subnet"
    subnets = var.subnets_wus2
    rg_name = module.rg_wus2.rg_name
    vnet_name = module.vnet_wus2.vnet_name
    # General variables
    system_code = var.system_code
    environment_code = var.environment_code
    location_code = var.location_code_wus2
    project_name = var.project_name
}

module "vnet_nsg_wus2" {
    source = "./modules/az-vnet-nsg"
    rg_location = module.rg_wus2.rg_location
    rg_name = module.rg_wus2.rg_name
    network_security_groups = var.network_security_groups_wus2
    
    # General variables
    system_code = var.system_code
    environment_code = var.environment_code
    location_code = var.location_code_wus2
    project_name = var.project_name
    project_tag = var.project_tag
}
locals {
    virtual_machines_wus2 = {
        for virtual_machine in var.virtual_machines_wus2 : virtual_machine.vm_name => virtual_machine
    }
}
module "vnet_vm_wus2" {
    for_each = local.virtual_machines_wus2
    source = "./modules/az-vm"
    rg_location = module.rg_wus2.rg_location
    rg_name = module.rg_wus2.rg_name
    virtual_machine = each.value
    subnet_id = module.subnet_wus2.vnet_subnets["${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code_wus2}-${each.value.subnet_name}-01"].id
    nsg_id = module.vnet_nsg_wus2.vnet_nsg["${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code_wus2}-${each.value.nsg_name}-nsg-01"].id

    # General variables
    system_code = var.system_code
    environment_code = var.environment_code
    location_code = var.location_code_wus2
    project_name = var.project_name
    project_tag = var.project_tag
}

############### Azure resource in EU ###############
module "rg_weu" {
    source = "./modules/az-resource-group"
    az_location = var.az_location_weu

    # General variables
    system_code = var.system_code
    environment_code = var.environment_code
    location_code = var.location_code_weu
    project_name = var.project_name
    project_tag = var.project_tag
}

module "vnet_weu" {
    source = "./modules/az-vnet"
    rg_location = module.rg_weu.rg_location
    rg_name = module.rg_weu.rg_name
    vnet_address_space = var.vnet_address_space_weu
    
    # General variables
    system_code = var.system_code
    environment_code = var.environment_code
    location_code = var.location_code_weu
    project_name = var.project_name
    project_tag = var.project_tag
}

module "subnet_weu" {
    source = "./modules/az-vnet-subnet"
    subnets = var.subnets_weu
    rg_name = module.rg_weu.rg_name
    vnet_name = module.vnet_weu.vnet_name
    # General variables
    system_code = var.system_code
    environment_code = var.environment_code
    location_code = var.location_code_weu
    project_name = var.project_name
}

module "vnet_nsg_weu" {
    source = "./modules/az-vnet-nsg"
    rg_location = module.rg_weu.rg_location
    rg_name = module.rg_weu.rg_name
    network_security_groups = var.network_security_groups_weu
    
    # General variables
    system_code = var.system_code
    environment_code = var.environment_code
    location_code = var.location_code_weu
    project_name = var.project_name
    project_tag = var.project_tag
}

locals {
    virtual_machines_weu = {
        for virtual_machine in var.virtual_machines_weu : virtual_machine.vm_name => virtual_machine
    }
}
module "vnet_vm_weu" {
    for_each = local.virtual_machines_weu
    source = "./modules/az-vm"
    rg_location = module.rg_weu.rg_location
    rg_name = module.rg_weu.rg_name
    virtual_machine = each.value
    subnet_id = module.subnet_weu.vnet_subnets["${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code_weu}-${each.value.subnet_name}-01"].id
    nsg_id = module.vnet_nsg_weu.vnet_nsg["${var.system_code}-${var.environment_code}-${var.project_name}-${var.location_code_weu}-${each.value.nsg_name}-nsg-01"].id

    # General variables
    system_code = var.system_code
    environment_code = var.environment_code
    location_code = var.location_code_weu
    project_name = var.project_name
    project_tag = var.project_tag
}

############### Vnet Peering WUS2-EU ###############
module "vnet_peering_wus2-eu" {
    source = "./modules/az-vnet-peering"
    vnet_peering_name = var.vnet_peering_name_wus2
    rg_name = module.rg_wus2.rg_name
    vnet_name = module.vnet_wus2.vnet_name
    remote_virtual_network_id = module.vnet_weu.vnet_id
    is_allow_virtual_network_access = var.is_allow_virtual_network_access
    is_allow_forwarded_traffic = var.is_allow_forwarded_traffic
    is_allow_gateway_transit = var.is_allow_gateway_transit
    
    # General variables
    system_code = var.system_code
    environment_code = var.environment_code
    location_code = var.location_code_wus2
    project_name = var.project_name
}

############### Vnet Peering WUS2-EU ###############
module "vnet_peering_eu-wus2" {
    source = "./modules/az-vnet-peering"
    vnet_peering_name = var.vnet_peering_name_weu
    rg_name = module.rg_weu.rg_name
    vnet_name = module.vnet_weu.vnet_name
    remote_virtual_network_id = module.vnet_wus2.vnet_id
    is_allow_virtual_network_access = var.is_allow_virtual_network_access
    is_allow_forwarded_traffic = var.is_allow_forwarded_traffic
    is_allow_gateway_transit = var.is_allow_gateway_transit
    
    # General variables
    system_code = var.system_code
    environment_code = var.environment_code
    location_code = var.location_code_weu
    project_name = var.project_name
}


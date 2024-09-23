############### General variables ###############
system_code      = "cariad"
environment_code = "dev"
project_tag = {
    ApplicationName = "cariad"
    OwnerService = "cariad"
    ProjectID = "cariad-dev"
}
project_name = "wp01"

############### Azure resource in West-US ###############
###### Resource Group Variables ######
location_code_wus2 = "wus2"
az_location_wus2 = "West US 2"

###### Vnet Variables ######
vnet_address_space_wus2 = "10.100.0.0/16"

###### Subnet Variables ######
subnets_wus2 = [
    {
        subnet_name = "public-subnet",
        subnet_address_prefixes = "10.100.1.0/24",
        is_private_subnet = true
    },
    {
        subnet_name = "private-subnet",
        subnet_address_prefixes = "10.100.2.0/24",
        is_private_subnet = false
    },
]

###### NetWork Security Group Variables ######
network_security_groups_wus2 = [
    {
        nsg_name = "wd-test-vm",
        security_rules = [
            {
                name = "Allow_port_3389_Testing",
                priority = 100,
                direction = "Inbound",
                access = "Allow",
                protocol = "Tcp",
                source_port_range = "*",
                destination_port_range = "3389",
                source_address_prefix = "*",
                destination_address_prefix = "*"
            }
        ]
    }
]

virtual_machines_wus2 = [
    {
        vm_name = "wd-test-vm"
        is_vm_linux = false
        is_vm_public = true
        subnet_name = "public-subnet"
        nsg_name = "wd-test-vm"
        vm_size = "Standard_B2s"
        is_delete_os_disk_on_termination = true
        is_delete_data_disks_on_termination = true
        storage_image_reference = {
            publisher = "MicrosoftWindowsDesktop"
            offer = "windows-11"
            sku = "win11-21h2-pro"
            version = "latest"
        }
        storage_os_disk = {
            caching = "ReadWrite"
            create_option = "FromImage"
            managed_disk_type = "Standard_LRS"
        }
        os_profile = {
            admin_username = "wdazuser"
            admin_password = "P@ssword1234!"
        }
        os_profile_linux_config = {
            disable_password_authentication = false
        }
    }
]

############### Azure resource in West-US ###############
###### Resource Group Variables ######
location_code_weu = "weu"
az_location_weu = "West Europe"

###### Vnet Variables ######
vnet_address_space_weu = "10.101.0.0/16"

###### Subnet Variables ######
subnets_weu = [
    {
        subnet_name = "public-subnet",
        subnet_address_prefixes = "10.101.1.0/24",
        is_private_subnet = true
    },
    {
        subnet_name = "private-subnet",
        subnet_address_prefixes = "10.101.2.0/24",
        is_private_subnet = false
    },
]

###### NetWork Security Group Variables ######
network_security_groups_weu = [
    {
        nsg_name = "file-server",
        security_rules = [
            {
                name = "Allow_port_80",
                priority = 100,
                direction = "Inbound",
                access = "Allow",
                protocol = "Tcp",
                source_port_range = "*",
                destination_port_range = "80",
                source_address_prefix = "*",
                destination_address_prefix = "*"
            },
            {
                name = "Allow_port_443",
                priority = 101,
                direction = "Inbound",
                access = "Allow",
                protocol = "Tcp",
                source_port_range = "*",
                destination_port_range = "443",
                source_address_prefix = "*",
                destination_address_prefix = "*"
            },
            {
                name = "Allow_port_22",
                priority = 102,
                direction = "Inbound",
                access = "Allow",
                protocol = "Tcp",
                source_port_range = "*",
                destination_port_range = "22",
                source_address_prefix = "*",
                destination_address_prefix = "*"
            }
        ]
    }
]

###### Virtual Machine Variables ######
virtual_machines_weu = [
    {
        vm_name = "file-server"
        is_vm_linux = true
        is_vm_public = true
        subnet_name = "public-subnet"
        nsg_name = "file-server"
        vm_size = "Standard_B2s"
        is_delete_os_disk_on_termination = true
        is_delete_data_disks_on_termination = true
        storage_image_reference = {
            publisher = "Canonical"
            offer = "0001-com-ubuntu-server-jammy"
            sku = "22_04-lts"
            version = "latest"
        }
        storage_os_disk = {
            caching = "ReadWrite"
            create_option = "FromImage"
            managed_disk_type = "Standard_LRS"
        }
        os_profile = {
            admin_username = "ubuntuazuser"
            admin_password = "P@ssword1234!"
        }
        os_profile_linux_config = {
            disable_password_authentication = false
        }
    }
]

############### Vnet Peering Variables ###############
vnet_peering_name_wus2 = "vnet-peering-wus2-to-weu"
vnet_peering_name_weu = "vnet-peering-weu-to-wus2"
is_allow_virtual_network_access = true
is_allow_forwarded_traffic = true
is_allow_gateway_transit =  false

#!/bin/bash
set -e

function check_installed {
    if ! command -v "$1" &> /dev/null; then
        echo "$1 is not installed. Please install it and run scrypt again."
    fi
}
##### VARIABLES #####
##### TO BE CHANGED #####
ARM_CLIENT_ID=""
ARM_CLIENT_SECRET=""
ARM_SUBSCRIPTION_ID=""
ARM_TENANT_ID=""

ADMIN_USERNAME=""
ADMIN_PASSWORD=""
PSQL_ADMIN_USERNAME=""
PSQL_ADMIN_PASSWORD=""
KC_ADMIN_USERNAME=""
KC_ADMIN_PASSWORD=""
SERVER_DOMAIN=""   # IMPORTANT: DNS NAME WITHOUT http:// or https:// !!!

##### DEFAULT VARIABLES #####
KEYCLOAK_VMS_COUNT=3    # TO SCALE UP KEYCLOAK SETUP INCREASE THE NUMBER OF THIS VARIABLE 
JAVA_VERSION="21"
KC_VERSION="25.0.0"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

check_installed "terraform"
check_installed "ansible"

##### TERRAFORM APPLY (Step 1) #####
cd $SCRIPT_DIR/../terraform/main
terraform init
terraform apply -var "keycloak_vms_count=$KEYCLOAK_VMS_COUNT" \
                -var "admin_username=$ADMIN_USERNAME" \
                -var "admin_password=$ADMIN_PASSWORD" \
                -var "psql_admin_username=$PSQL_ADMIN_USERNAME" \
                -var "psql_admin_password=$PSQL_ADMIN_PASSWORD" \
                -var "kc_admin_username=$KC_ADMIN_USERNAME" \
                -var "kc_admin_password=$KC_ADMIN_PASSWORD" \
                -var "kc_version=$KC_VERSION" \
                -var "java_version=$JAVA_VERSION" \
                -var "server_domain=$SERVER_DOMAIN" \
                -var "client_id=$ARM_CLIENT_ID" \
                -var "client_secret=$ARM_CLIENT_SECRET" \
                -var "subscription_id=$ARM_SUBSCRIPTION_ID" \
                -var "tenant_id=$ARM_TENANT_ID" \
                -target=module.resource_group \
                -target=module.network_security_group \
                -target=module.psql_network_security_group \
                -target=module.virtual_network \
                -target=module.default_subnet \
                -target=module.db_subnet \
                -target=module.virtual_machine \
                -target=module.virtual_machine_webapp \
                -target=module.monitor_data_collection_rule \
                -target=module.monitor_data_collection_rule_association \
                -target=module.log_analytics_workspace \
                -target=module.public_ip_webapp \
                -target=module.public_ip_vm \
                -target=module.postgresql \
                -target=module.backup_services_vault

# Prompt user to update DNS
WEBAPP_PUBLIC_IP=$(terraform output -raw webapp_public_ip)
echo "=================================================================="
echo "                          IMPORTANT!                              "
echo "=================================================================="
echo "Please update your DNS settings to point the domain:"
echo "  ${SERVER_DOMAIN}"
echo "to the following public IP address:"
echo "  ${WEBAPP_PUBLIC_IP}"
echo "This step is crucial for the proper functioning of your application."
echo "Please check manually if the DNS has been updated befor continuing."
echo "=================================================================="
read -p "Has the DNS been updated? (yes/no): " dns_updated

if [ "$dns_updated" != "yes" ]; then
  echo "Please update the DNS and run the script again."
  exit 1
fi

##### TERRAFORM APPLY (Step 2) #####
terraform apply -var "keycloak_vms_count=$KEYCLOAK_VMS_COUNT" \
                -var "admin_username=$ADMIN_USERNAME" \
                -var "admin_password=$ADMIN_PASSWORD" \
                -var "psql_admin_username=$PSQL_ADMIN_USERNAME" \
                -var "psql_admin_password=$PSQL_ADMIN_PASSWORD" \
                -var "kc_admin_username=$KC_ADMIN_USERNAME" \
                -var "kc_admin_password=$KC_ADMIN_PASSWORD" \
                -var "kc_version=$KC_VERSION" \
                -var "java_version=$JAVA_VERSION" \
                -var "server_domain=$SERVER_DOMAIN" \
                -var "client_id=$ARM_CLIENT_ID" \
                -var "client_secret=$ARM_CLIENT_SECRET" \
                -var "subscription_id=$ARM_SUBSCRIPTION_ID" \
                -var "tenant_id=$ARM_TENANT_ID" \
                -target=null_resource.ansible_playbook

echo "=================================================================="
echo "                       CONGRATULATIONS!                           "
echo "=================================================================="
echo "Your HA Keycloak cluster has been successfully created."
echo "You can access the Keycloak Test Application at:"
echo "            https://${SERVER_DOMAIN} "
echo "=================================================================="

#!/bin/bash

##### VARIABLES #####
ADMIN_USERNAME=""
ADMIN_PASSWORD=""
ARM_CLIENT_ID=""
ARM_CLIENT_SECRET=""
ARM_SUBSCRIPTION_ID=""
ARM_TENANT_ID=""
RUNNER_TOKEN=""

##### TERRAFORM VARIABLES #####
TF_VARS="-var client_id=$ARM_CLIENT_ID \
         -var client_secret=$ARM_CLIENT_SECRET \
         -var subscription_id=$ARM_SUBSCRIPTION_ID \
         -var tenant_id=$ARM_TENANT_ID \
         -var admin_username=$ADMIN_USERNAME \
         -var admin_password=$ADMIN_PASSWORD \
         -var runner_token=$RUNNER_TOKEN"

##### TERRAFORM #####
cd ../terraform/main

# Initialize Terraform with variables
terraform init $TF_VARS

# Plan the infrastructure changes
terraform plan $TF_VARS

# Apply the infrastructure changes
terraform apply $TF_VARS

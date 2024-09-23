#!/bin/bash

##### VARIABLES #####
ADMIN_USERNAME=""
ADMIN_PASSWORD=""
ARM_CLIENT_ID=""
ARM_CLIENT_SECRET=""
ARM_SUBSCRIPTION_ID=""
ARM_TENANT_ID=""
ZENDESK_SUBDOMAIN=""
ZENDESK_EMAIL=""
ZENDESK_TICKET_URL="" # Refers to tickets endpoint https://<your_subdomain>.zendesk.com/api/v2/tickets.json
ZENDESK_SEARCH_URL="" # Refers to search endpoint https://<your_subdomain>.zendesk.com/api/v2/search.json
ZENDESK_GROUP=""
JIRA_EMAIL=""
JIRA_API_TOKEN=""
JIRA_SEARCH_URL="" # Refers to search endpoint of the JIRA API "https://<your_subdomain>.atlassian.net/rest/api/2/search?jql=project=<project_key>"
JIRA_STATUS_FIELD_ID="" # Refers to an id of a status field once it is created in Zendesk
JIRA_ISSUE_KEY_FIELD_ID="" # Refers to an id of a issue key field once it is created in Zendesk
SLACK_BOT_TOKEN="" 
SLACK_APP_TOKEN=""
GROUP_ID_SLACK=""

##### TERRAFORM #####
VARS_TF="-var client_id=$ARM_CLIENT_ID \
         -var client_secret=$ARM_CLIENT_SECRET \
         -var subscription_id=$ARM_SUBSCRIPTION_ID \
         -var tenant_id=$ARM_TENANT_ID \
         -var admin_username=$ADMIN_USERNAME \
         -var admin_password=$ADMIN_PASSWORD \
         -var zendesk_subdomain=$ZENDESK_SUBDOMAIN \
         -var zendesk_email=$ZENDESK_EMAIL \
         -var zendesk_api_token=$ZENDESK_API_TOKEN \
         -var zendesk_group=$ZENDESK_GROUP \
         -var zendesk_ticket_url=$ZENDESK_TICKET_URL \
         -var zendesk_search_url=$ZENDESK_SEARCH_URL \
         -var jira_email=$JIRA_EMAIL \
         -var jira_api_token=$JIRA_API_TOKEN \
         -var jira_search_url=$JIRA_SEARCH_URL \
         -var jira_status_field_id=$JIRA_STATUS_FIELD_ID \
         -var jira_issue_key_field_id=$JIRA_ISSUE_KEY_FIELD_ID \
         -var slack_bot_token=$SLACK_BOT_TOKEN \
         -var slack_app_token=$SLACK_APP_TOKEN \
         -var group_id_slack=$GROUP_ID_SLACK"

##### TERRAFORM #####
cd ../terraform/main
terraform init $VARS_TF
terraform plan $VARS_TF
terraform apply $VARS_TF

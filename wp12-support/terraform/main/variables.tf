variable "client_id" {}
variable "client_secret" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "admin_username" {}
variable "admin_password" {}
variable "zendesk_subdomain" {}
variable "zendesk_email" {}
variable "zendesk_api_token" {}
variable "zendesk_group" {}
variable "zendesk_ticket_url" {}
variable "zendesk_search_url" {}
variable "jira_email" {}
variable "jira_api_token" {}
variable "jira_search_url" {}
variable "jira_status_field_id" {}
variable "jira_issue_key_field_id" {}
variable "group_id_slack" {}
variable "slack_app_token" {}
variable "slack_bot_token" {}
variable "tags" {
  default = {
    project-name = "cariad-ticket-consolidator"
    environment  = "demo"
    created-by   = "milos.stojic@p3-group.com, aleksandar.cevap@p3-group.com"
  }
}

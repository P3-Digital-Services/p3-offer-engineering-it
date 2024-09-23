variable "subscription_id" {
  description = "Subscription id"
  type        = string
  default     = "06266e31-e444-4db4-9a0a-bf6c4f00d723"
}
output "subcription_id" {
  description = "Subscription id"
  value       = var.subscription_id
}
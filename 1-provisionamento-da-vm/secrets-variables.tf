variable "azure_client_id" {
  description = "Client ID for Azure provider"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Client Secret for Azure provider"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Tenant ID for Azure provider"
  type        = string
}

variable "azure_subscription_id" {
  description = "Subscription ID for Azure provider"
  type        = string
}
resource "azurerm_resource_group" "keycloak_rancher" {
  name     = var.azure_resource_group
  location = var.azure_location
}

provider "azurerm" {
  features {}

  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

provider "kubernetes" {
  config_path = "/home/gilberto/.kube/config"
  insecure    = true
}

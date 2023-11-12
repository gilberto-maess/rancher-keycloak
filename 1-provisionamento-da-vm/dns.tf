resource "azurerm_dns_zone" "keycloak_rancher" {
  depends_on          = [azurerm_public_ip.keycloak_rancher_ip_v4]
  name                = "ferreira.dev.br"
  resource_group_name = azurerm_resource_group.keycloak_rancher.name
  tags = {
    Environment = "Production"
  }
}

resource "azurerm_dns_a_record" "record-ipv4" {
  depends_on          = [azurerm_dns_zone.keycloak_rancher]
  for_each            = toset(var.subdomains)
  name                = each.value
  zone_name           = var.azure_dominio
  resource_group_name = var.azure_resource_group
  ttl                 = 300
  records             = [azurerm_public_ip.keycloak_rancher_ip_v4.ip_address]
}
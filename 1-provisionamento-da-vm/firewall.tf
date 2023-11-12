resource "azurerm_network_security_group" "keycloak_rancher" {
  depends_on          = [azurerm_linux_virtual_machine.keycloak_rancher]
  name                = "nsg"
  location            = "East US"
  resource_group_name = var.azure_resource_group

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSHMyIP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.meu_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow32017MyIP"
    priority                   = 111
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "32017"
    source_address_prefix      = var.meu_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow16443MyIP"
    priority                   = 112
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "16443"
    source_address_prefix      = var.meu_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow2049ForSpecificIP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2049"
    source_address_prefix      = azurerm_public_ip.keycloak_rancher_ip_v4.ip_address
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow2049ForSpecificIPUDP"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "2049"
    source_address_prefix      = azurerm_public_ip.keycloak_rancher_ip_v4.ip_address
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "EgressAll"
    priority                   = 140
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65535"
    source_address_prefix      = "*"
    destination_address_prefix = "0.0.0.0/0"
  }
}

resource "azurerm_subnet_network_security_group_association" "keycloak_rancher" {
  depends_on                = [azurerm_network_security_group.keycloak_rancher]
  subnet_id                 = azurerm_subnet.keycloak_rancher.id
  network_security_group_id = azurerm_network_security_group.keycloak_rancher.id
}

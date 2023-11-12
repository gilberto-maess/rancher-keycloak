resource "azurerm_virtual_network" "keycloak_rancher" {
  depends_on          = [azurerm_resource_group.keycloak_rancher]
  name                = "keycloak_rancher"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.keycloak_rancher.location
  resource_group_name = azurerm_resource_group.keycloak_rancher.name
}

resource "azurerm_subnet" "keycloak_rancher" {
  depends_on           = [azurerm_virtual_network.keycloak_rancher]
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.keycloak_rancher.name
  virtual_network_name = azurerm_virtual_network.keycloak_rancher.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "keycloak_rancher" {
  depends_on          = [azurerm_subnet.keycloak_rancher]
  name                = "nic"
  location            = azurerm_resource_group.keycloak_rancher.location
  resource_group_name = azurerm_resource_group.keycloak_rancher.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.keycloak_rancher.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.keycloak_rancher_ip_v4.id
  }
}

resource "azurerm_public_ip" "keycloak_rancher_ip_v4" {
  name                = "ipv4"
  location            = azurerm_resource_group.keycloak_rancher.location
  resource_group_name = azurerm_resource_group.keycloak_rancher.name
  allocation_method   = "Static"
  tags = {
    environment = "Production"
  }
}
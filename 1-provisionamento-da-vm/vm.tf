resource "azurerm_linux_virtual_machine" "keycloak_rancher" {
  depends_on = [azurerm_public_ip.keycloak_rancher_ip_v4]

  name                = var.vm_name
  resource_group_name = azurerm_resource_group.keycloak_rancher.name
  location            = azurerm_resource_group.keycloak_rancher.location
  size                = var.vm_size
  admin_username      = "ubuntu"
  network_interface_ids = [
    azurerm_network_interface.keycloak_rancher.id,
  ]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file(var.chave_ssh)
  }

  os_disk {
    name                 = "rancher_keycloak-disk"
    caching              = "ReadWrite"
    storage_account_type = var.vm_storage_account_type
    disk_size_gb         = var.vm_disk_size
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  provisioner "file" {
    source      = "./scripts/"
    destination = "/tmp/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = azurerm_public_ip.keycloak_rancher_ip_v4.ip_address
    }
  }
}
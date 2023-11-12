resource "null_resource" "setup_do_server" {
  depends_on = [azurerm_linux_virtual_machine.keycloak_rancher]

  triggers = {
    nfs_directories = "${jsonencode(var.nfs_directories)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup.sh",
      "export RANCHER_SUBDOMAIN=rancher.${var.azure_dominio}",
      "export LETSENCRYPT_EMAIL=${var.letsEncrypt_email}",
      "export IPV4_SERVER=${azurerm_public_ip.keycloak_rancher_ip_v4.ip_address}",
      "sh /tmp/setup.sh"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = azurerm_public_ip.keycloak_rancher_ip_v4.ip_address
    }
  }

  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no ubuntu@${azurerm_public_ip.keycloak_rancher_ip_v4.ip_address} 'sudo cat /var/snap/microk8s/current/credentials/client.config' > ~/.kube/config"
  }

  provisioner "local-exec" {
    command = "sed -i 's/127.0.0.1/${azurerm_public_ip.keycloak_rancher_ip_v4.ip_address}/g' ~/.kube/config"
  }
}
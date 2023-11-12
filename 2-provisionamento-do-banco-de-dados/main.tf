provider "kubernetes" {
  config_path = var.kube_config_full_path
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace_app
  }
}

resource "kubernetes_namespace" "cattle_monitoring_system" {
  metadata {
    name = "cattle-monitoring-system"
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kube_config_path
  }
}

resource "null_resource" "helm_repo_addition" {
  provisioner "remote-exec" {
    inline = [
      "echo 'Verificando repositório bitnami...'",
      "if ! microk8s helm repo list | grep -q '^bitnami'; then",
      "    echo 'Adicionando repositório bitnami...'",
      "    microk8s helm repo add bitnami https://charts.bitnami.com/bitnami",
      "fi",
      "echo 'Atualizando repositórios helm...'",
      "microk8s helm repo update"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key)
      host        = var.server
    }
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

resource "kubernetes_secret" "all_secrets" {
  for_each = var.all_secrets

  metadata {
    name      = each.key
    namespace = var.namespace_app
  }

  data = {
    for k, v in each.value : k => v
  }

  type = "Opaque"
}
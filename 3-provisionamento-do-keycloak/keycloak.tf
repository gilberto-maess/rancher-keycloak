resource "kubernetes_persistent_volume" "keycloak_themes" {
  metadata {
    name = "keycloak-themes"
  }

  spec {
    capacity = {
      storage = "1Gi"
    }

    storage_class_name = "nfs"

    access_modes = ["ReadWriteOnce"]

    persistent_volume_source {
      nfs {
        path   = "/ubuntu/app/sso/themes"
        server = var.server
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "keycloak_themes" {
  depends_on = [kubernetes_persistent_volume.keycloak_themes]
  metadata {
    name      = "keycloak-themes"
    namespace = var.namespace_app
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    volume_name = "keycloak-themes"

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    storage_class_name = "nfs"
  }
}

resource "kubernetes_deployment" "keycloak" {
  depends_on = [kubernetes_persistent_volume_claim.keycloak_themes]
  metadata {
    name      = "keycloak"
    namespace = var.namespace_app
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "keycloak"
      }
    }

    template {
      metadata {
        labels = {
          app = "keycloak"
        }
      }

      spec {
        container {
          name  = "keycloak"
          image = "quay.io/keycloak/keycloak:22.0.5"

          args = [
            "start",
            "--spi-theme-static-max-age=-1",
            "--spi-theme-cache-themes=false",
            "--spi-theme-cache-templates=false",
          ]

          env {
            name  = "KC_DB"
            value = "mariadb"
          }

          env {
            name  = "KC_DB_URL"
            value = "jdbc:mariadb://mariadb/keycloak"
          }

          env {
            name  = "KC_HEALTH_ENABLED"
            value = "true"
          }

          env {
            name  = "KC_METRICS_ENABLED"
            value = "true"
          }

          env {
            name  = "KC_PROXY"
            value = "edge"
          }

          env {
            name  = "KC_SPI_STICKY_SESSION_ENCODER_INFINISPAN_SHOULD_ATTACH_ROUTE"
            value = "false"
          }

          env {
            name  = "KC_HOSTNAME_STRICT"
            value = "false"
          }

          env {
            name  = "KC_HTTP_ENABLED"
            value = "true"
          }

          env {
            name  = "KC_HOSTNAME"
            value = var.sso-hostname
          }

          env {
            name = "KC_DB_USERNAME"
            value_from {
              secret_key_ref {
                name = "mariadb-secrets"
                key  = "username"
              }
            }
          }

          env {
            name = "KC_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mariadb-secrets"
                key  = "mariadb-password"
              }
            }
          }

          volume_mount {
            name       = "keycloak-themes"
            mount_path = "/opt/keycloak/themes"
          }
        }

        volume {
          name = "keycloak-themes"

          persistent_volume_claim {
            claim_name = "keycloak-themes"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "keycloak" {
  depends_on = [kubernetes_deployment.keycloak]
  metadata {
    name      = "keycloak"
    namespace = var.namespace_app
  }

  spec {
    selector = {
      app = "keycloak"
    }

    port {
      name        = "keycloak"
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_ingress_v1" "keycloak" {

  depends_on = [kubernetes_service.keycloak]

  metadata {
    name      = "keycloak"
    namespace = var.namespace_app
    annotations = {
      "cert-manager.io/cluster-issuer" : "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect" : "true"
      "nginx.ingress.kubernetes.io/proxy-buffer-size" : "128k"
      "nginx.ingress.kubernetes.io/proxy-buffers" : "4 256k"
      "nginx.ingress.kubernetes.io/proxy-busy-buffers-size" : "256k"
    }
  }

  spec {
    rule {
      host = "sso.${var.dominio}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "keycloak"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = ["sso.${var.dominio}"]
      secret_name = "keycloak-certificate"
    }
  }
}

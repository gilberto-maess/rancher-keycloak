resource "helm_release" "mariadb" {
  name       = "mariadb"
  namespace  = var.namespace_app
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mariadb"

  set {
    name  = "auth.password"
    value = var.all_secrets["mariadb-secrets"].mariadb-password
  }

  set {
    name  = "auth.rootPassword"
    value = var.all_secrets["mariadb-secrets"].mariadb-root-password
  }

  set {
    name  = "auth.replicationPassword"
    value = var.all_secrets["mariadb-secrets"].mariadb-replication-password
  }

  set {
    name  = "auth.username"
    value = var.all_secrets["mariadb-secrets"].mariadb-username
  }

  set {
    name  = "auth.database"
    value = "keycloak"
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }

  set {
    name  = "metrics.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "primary.configuration"
    value = <<-EOT
      [mysqld]
      lower_case_table_names=1
      skip-name-resolve
      explicit_defaults_for_timestamp
      basedir=/opt/bitnami/mariadb
      datadir=/bitnami/mariadb/data
      plugin_dir=/opt/bitnami/mariadb/plugin
      port=3306
      socket=/opt/bitnami/mariadb/tmp/mysql.sock
      tmpdir=/opt/bitnami/mariadb/tmp
      max_allowed_packet=16M
      bind-address=*
      pid-file=/opt/bitnami/mariadb/tmp/mysqld.pid
      log-error=/opt/bitnami/mariadb/logs/mysqld.log
      character-set-server=UTF8
      collation-server=utf8_general_ci
      slow_query_log=0
      long_query_time=10.0

      [client]
      port=3306
      socket=/opt/bitnami/mariadb/tmp/mysql.sock
      default-character-set=UTF8
      plugin_dir=/opt/bitnami/mariadb/plugin

      [manager]
      port=3306
      socket=/opt/bitnami/mariadb/tmp/mysql.sock
      pid-file=/opt/bitnami/mariadb/tmp/mysqld.pid
    EOT
  }

  set {
    name  = "secondary.configuration"
    value = <<-EOT
      [mysqld]
      lower_case_table_names=1
      skip-name-resolve
      explicit_defaults_for_timestamp
      basedir=/opt/bitnami/mariadb
      datadir=/bitnami/mariadb/data
      port=3306
      socket=/opt/bitnami/mariadb/tmp/mysql.sock
      tmpdir=/opt/bitnami/mariadb/tmp
      max_allowed_packet=16M
      bind-address=0.0.0.0
      pid-file=/opt/bitnami/mariadb/tmp/mysqld.pid
      log-error=/opt/bitnami/mariadb/logs/mysqld.log
      character-set-server=UTF8
      collation-server=utf8_general_ci
      slow_query_log=0
      long_query_time=10.0

      [client]
      port=3306
      socket=/opt/bitnami/mariadb/tmp/mysql.sock
      default-character-set=UTF8

      [manager]
      port=3306
      socket=/opt/bitnami/mariadb/tmp/mysql.sock
      pid-file=/opt/bitnami/mariadb/tmp/mysqld.pid
    EOT
  }

  depends_on = [null_resource.helm_repo_addition, kubernetes_secret.all_secrets]
}
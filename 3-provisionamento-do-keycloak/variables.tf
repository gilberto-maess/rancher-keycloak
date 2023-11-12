variable "server" {
  default = "172.191.14.214"
  type    = string
}

variable "namespace_app" {
  default = "maess"
  type    = string
}

variable "kube_config_full_path" {
  default = "/home/gilberto/.kube/config"
  type    = string
}

variable "sso-hostname" {
  default = "sso.meudominio.com.br"
  type    = string
}

variable "dominio" {
  default = "meudominio.com.br"
  type    = string
}
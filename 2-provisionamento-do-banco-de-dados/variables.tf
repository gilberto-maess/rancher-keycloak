variable "server" {
  default = "172.191.14.214"
  type    = string
}

variable "namespace_app" {
  default = "maess"
  type    = string
}

variable "kube_config_path" {
  default = "~/.kube/config"
  type    = string
}

variable "kube_config_full_path" {
  default = "/home/gilberto/.kube/config"
  type    = string
}

variable "private_key" {
  default = "~/.ssh/id_rsa"
  type    = string
}

variable "all_secrets" {
  description = "All the secrets grouped by their usage"
  type        = map(map(string))
}
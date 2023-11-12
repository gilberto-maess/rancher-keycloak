variable "azure_resource_group" {
  description = "Resource Group Azure DNS Zone"
  default     = "keycloakrancher"
  type        = string
}

variable "azure_location" {
  default     = "East US"
  type        = string
}

variable "vm_name" {
  default     = "antares"
  type        = string
}

variable "vm_size" {
  default     = "Standard_B8ms"
  type        = string
}

variable "vm_storage_account_type" {
  default     = "Standard_LRS"
  type        = string
}

variable "vm_disk_size" {
  default     = "256"
  type        = string
}

variable "azure_dominio" {
  description = "Domínio da aplicação"
  default     = "meudominio.com.br"
  type        = string
}

variable "letsEncrypt_email" {
  default = "email@email.com"
  type    = string
}

variable "meu_ip" {
  default = "201.17.115.137"
  type    = string
}

variable "chave_ssh" {
  default = "~/.ssh/id_rsa.pub"
  type    = string
}

variable "kube_config_path" {
  default = "/home/gilberto/.kube/config"
  type    = string
}

variable "rancher_subdomain" {
  default = "rancher"
  type    = string
}

variable "subdomains" {
  description = "List of subdomains"
  default = [
    "rancher",
    "sso"
  ]
  type = list(string)
}

variable "nfs_directories" {
  description = "Lista de diretórios para NFS"
  type        = list(string)
  default     = ["/app/sso/themes"]
}
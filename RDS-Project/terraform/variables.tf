variable "resource_group_name" {
  default = "rg-rds-poc"
}

variable "location" {
  default = "East US"
}

variable "admin_username" {
  default = "azureadmin"
}

variable "admin_password" {
  sensitive = true
}

variable "tenant_id" {}

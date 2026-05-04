variable "name" {
  type = string
  description = "Name of the AKS cluster"
}

variable "location" {
  type = string
  description = "Azure region for AKS deployment"
}

variable "rg" {
  type = string
  description = "Resource group name"
}

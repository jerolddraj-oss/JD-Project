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

variable "subnet_id" {
  type = string
  description = "The ID of the subnet in which the AKS cluster will be deployed"
  default = null
}

variable "aks_id" {
  type = string
  description = "The ID of the AKS cluster"
  default = null
}
variable "name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "location" {
  type        = string
  description = "Azure region for AKS deployment"
}

variable "rg" {
  type        = string
  description = "Resource group name"
}

variable "create_private_cluster" {
  type        = bool
  description = "Whether to deploy a private AKS cluster and private endpoint"
  default     = false
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID used for private AKS node pool and private endpoint"
  default     = null
}

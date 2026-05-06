###################################################
# General Variables
###################################################

variable "resource_group_name" {
  description = "Azure Resource Group Name"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
  default     = "poc"
}

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "rds-project"
}

###################################################
# Network Variables
###################################################

variable "management_subnet_id" {
  description = "Management Subnet ID"
  type        = string
}

variable "sessionhost_subnet_id" {
  description = "Session Host Subnet ID"
  type        = string
}

variable "allowed_management_ip" {
  description = "Allowed public IP for management access"
  type        = string
}

variable "spoke_vnet_address_space" {
  description = "Spoke VNET Address Space"
  type        = string
}
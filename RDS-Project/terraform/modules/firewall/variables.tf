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

variable "gateway_subnet_id" {
  description = "Gateway Subnet ID"
  type        = string
}

variable "allowed_management_ip" {
  description = "Allowed Public IP"
  type        = string
}

variable "hub_vnet_address_space" {
  description = "Hub VNET Address Space"
  type        = string
}
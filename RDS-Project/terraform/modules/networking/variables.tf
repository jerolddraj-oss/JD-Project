###################################################
# General Variables
###################################################

variable "resource_group_name" {
  description = "Resource Group Name"
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
# Hub Network Variables
###################################################

variable "hub_vnet_name" {
  description = "Hub Virtual Network Name"
  type        = string
}

variable "hub_vnet_address_space" {
  description = "Hub Address Space"
  type        = list(string)
}

###################################################
# Spoke Network Variables
###################################################

variable "spoke_vnet_name" {
  description = "Spoke Virtual Network Name"
  type        = string
}

variable "spoke_vnet_address_space" {
  description = "Spoke Address Space"
  type        = list(string)
}

###################################################
# Subnet Variables
###################################################

variable "gateway_subnet_prefix" {
  description = "Gateway Subnet Prefix"
  type        = string
}

variable "management_subnet_prefix" {
  description = "Management Subnet Prefix"
  type        = string
}

variable "sessionhost_subnet_prefix" {
  description = "Session Host Subnet Prefix"
  type        = string
}
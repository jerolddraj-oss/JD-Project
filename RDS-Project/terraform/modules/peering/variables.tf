###################################################
# General Variables
###################################################

variable "resource_group_name" {
  description = "Azure Resource Group Name"
  type        = string
}

###################################################
# Hub Network Variables
###################################################

variable "hub_vnet_name" {
  description = "Hub Virtual Network Name"
  type        = string
}

variable "hub_vnet_id" {
  description = "Hub Virtual Network ID"
  type        = string
}

###################################################
# Spoke Network Variables
###################################################

variable "spoke_vnet_name" {
  description = "Spoke Virtual Network Name"
  type        = string
}

variable "spoke_vnet_id" {
  description = "Spoke Virtual Network ID"
  type        = string
}
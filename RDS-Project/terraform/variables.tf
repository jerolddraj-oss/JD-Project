###################################################
# Global Variables
###################################################

variable "location" {
  description = "Azure Region for deployment"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "poc"
}

variable "project_name" {
  description = "Project Name"
  type        = string
  default     = "rds-project"
}

###################################################
# Resource Group
###################################################

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
}

###################################################
# Networking Variables
###################################################

variable "hub_vnet_name" {
  description = "Hub Virtual Network Name"
  type        = string
}

variable "spoke_vnet_name" {
  description = "Spoke Virtual Network Name"
  type        = string
}

variable "hub_vnet_address_space" {
  description = "Hub VNET Address Space"
  type        = list(string)
}

variable "spoke_vnet_address_space" {
  description = "Spoke VNET Address Space"
  type        = list(string)
}

variable "gateway_subnet_prefix" {
  description = "Gateway subnet address prefix"
  type        = string
}

variable "management_subnet_prefix" {
  description = "Management subnet address prefix"
  type        = string
}

variable "sessionhost_subnet_prefix" {
  description = "Session host subnet prefix"
  type        = string
}

###################################################
# Virtual Machine Variables
###################################################

variable "admin_username" {
  description = "Administrator Username"
  type        = string
}

variable "admin_password" {
  description = "Administrator Password"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Azure VM Size"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "rd_gateway_vm_name" {
  description = "RD Gateway VM Name"
  type        = string
}

variable "rd_broker_vm_name" {
  description = "RD Broker VM Name"
  type        = string
}

variable "rd_session_host_count" {
  description = "Number of RD Session Hosts"
  type        = number
  default     = 2
}
variable "allowed_management_ip" {
  description = "Public IP allowed for management access"
  type        = string
}
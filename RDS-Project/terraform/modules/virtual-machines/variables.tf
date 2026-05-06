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
# Authentication Variables
###################################################

variable "admin_username" {
  description = "VM Administrator Username"
  type        = string
}

variable "admin_password" {
  description = "VM Administrator Password"
  type        = string
  sensitive   = true
}

###################################################
# VM Variables
###################################################

variable "vm_size" {
  description = "Azure VM Size"
  type        = string
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
  description = "Number of Session Hosts"
  type        = number
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

###################################################
# Static IP Variables
###################################################

variable "rd_gateway_private_ip" {
  description = "RD Gateway Static Private IP"
  type        = string
}

variable "rd_broker_private_ip" {
  description = "RD Broker Static Private IP"
  type        = string
}
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "name" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "vm_size" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "zones" {
  type    = list(string)
  default = []
}

variable "tags" {
  type = map(string)
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "ssh_public_key_path" {
  type    = string
  default = ""
}

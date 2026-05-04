variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "peer_vnet_name" {
  type = string
}

variable "peer_vnet_id" {
  type = string
}

variable "allow_forwarded_traffic" {
  type    = bool
  default = false
}

variable "allow_gateway_transit" {
  type    = bool
  default = false
}

variable "use_remote_gateways" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
}

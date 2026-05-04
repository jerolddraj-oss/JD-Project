variable "resource_group_name" {
  type = string
}

variable "hub_vnet_id" {
  type = string
}

variable "hub_vnet_name" {
  type = string
}

variable "spokes" {
  type = map(object({
    id   = string
    name = string
  }))
}

variable "allow_forwarded_traffic" {
  type    = bool
  default = true
}

variable "allow_gateway_transit" {
  type    = bool
  default = true
}

variable "location" {
  default = "East US"
}

variable "regions" {
  default = ["East US", "Central US", "West Europe"]
}

variable "hub_vnet_id" {
  type        = string
  description = "The ID of the hub virtual network for DNS peering"
}
variable "location" {}
variable "rg" {}
variable "firewall_subnet_id" {}
variable "public_ip_id" {}
variable "hub_vnet_id" {
  description = "The ID of the Hub Virtual Network"
  type        = string
}
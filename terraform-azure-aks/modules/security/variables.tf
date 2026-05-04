variable "location" {type=string}
variable "resource_group_name" {type=string}
variable "hub_vnet_id" {type=string}
variable "firewall_subnet_id" {type=string}
variable "appgw_subnet_id" {type=string}
variable "aks_subnet_cidr" {type=string}
variable "appgw_backend_address_pool_ip" {type=string}
variable "tags" {type=map(string)}

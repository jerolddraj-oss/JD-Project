variable "resource_group_name" {type=string}
variable "traffic_manager_name" {type=string}
variable "dns_relative_name" {type=string}
variable "appgw_public_fqdn" {type=string}
variable "vmss_public_ips" {type=list(string)}
variable "tags" {type=map(string)}

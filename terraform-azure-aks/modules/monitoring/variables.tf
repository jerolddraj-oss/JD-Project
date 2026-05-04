variable "location" {type=string}
variable "resource_group_name" {type=string}
variable "tags" {type=map(string)}
variable "spoke_vnet_id" {type=string}
variable "monitor_subnet_id" {type=string}
variable "private_dns_zone_name" {type=string}
variable "log_analytics_sku" {type=string}
variable "log_analytics_retention" {type=number}

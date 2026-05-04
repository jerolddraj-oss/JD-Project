variable "location" {type=string}
variable "resource_group_name" {type=string}
variable "key_vault_name" {type=string}
variable "tenant_id" {type=string}
variable "object_id" {type=string}
variable "aks_kubeconfig" {type=string sensitive=true}
variable "app_secret_value" {type=string sensitive=true}
variable "tags" {type=map(string)}

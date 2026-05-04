variable "resource_group_name" { type = string }
variable "cluster_name" { type = string }
variable "node_pool_name" { type = string }
variable "vm_size" { type = string }
variable "node_count" { type = number }
variable "tags" { type = map(string) }

resource "azurerm_kubernetes_cluster_node_pool" "np" {
  name                = var.node_pool_name
  kubernetes_cluster_id = data.azurerm_kubernetes_cluster.cluster.id
  vm_size             = var.vm_size
  node_count          = var.node_count
  availability_zones  = ["1","2"]
  mode                = "User"
  tags                = var.tags
}

data "azurerm_kubernetes_cluster" "cluster" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

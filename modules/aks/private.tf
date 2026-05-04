resource "azurerm_kubernetes_cluster" "aks_private" {
  count               = var.create_private_cluster ? 1 : 0
  name                = "${var.name}-private"
  location            = var.location
  resource_group_name = var.rg
  dns_prefix          = "${var.name}-private"

  private_cluster_enabled = true

  default_node_pool {
    name           = "nodepool"
    node_count     = 2
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }
}

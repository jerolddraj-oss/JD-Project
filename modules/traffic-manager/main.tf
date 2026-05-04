resource "azurerm_traffic_manager_profile" "tm" {
  name                = "jd-traffic-manager"
  resource_group_name = var.rg

  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "jd-global-aks"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/"
  }
}

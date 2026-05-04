resource "azurerm_log_analytics_workspace" "log" {
  name                = "jd-law"
  location            = var.location
  resource_group_name = var.rg
  sku                 = "PerGB2018"
}

resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "cpu-alert"
  resource_group_name = var.rg
  scopes              = var.resource_ids

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    operator         = "GreaterThan"
    threshold        = 80
    aggregation      = "Average"
  }

  evaluation_frequency = "PT1M"
  window_size          = "PT5M"
  severity             = 3
}

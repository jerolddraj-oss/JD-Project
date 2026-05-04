variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "profile_name" { type = string }
variable "endpoints" { type = list(object({
  name = string
  type = string
  target = string
  priority = number
  geo = string
})) }
variable "tags" { type = map(string) }

resource "azurerm_traffic_manager_profile" "tm" {
  name                = var.profile_name
  resource_group_name = var.resource_group_name
  location            = "global"
  profile_status      = "Enabled"
  traffic_routing_method = "Geographic"
  dns_config {
    relative_name = var.profile_name
    ttl           = 30
  }
  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/"
  }
  tags = var.tags
}

resource "azurerm_traffic_manager_endpoint" "endpoints" {
  for_each = { for e in var.endpoints : e.name => e }
  name                = each.value.name
  profile_name        = azurerm_traffic_manager_profile.tm.name
  resource_group_name = var.resource_group_name
  type                = "externalEndpoints"
  target              = each.value.target
  priority            = each.value.priority
  geo_mapping         = [each.value.geo]
}

output "fqdn" {
  value = azurerm_traffic_manager_profile.tm.fqdn
}

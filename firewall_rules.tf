resource "azurerm_firewall_network_rule_collection" "allow_internet" {
  name                = "allow-internet"
  azure_firewall_name = module.network_security.firewall_name
  resource_group_name = azurerm_resource_group.main.name
  priority            = 100
  action              = "Allow"

  rule {
    name                  = "allow-http"
    source_addresses      = ["*"]
    destination_ports     = ["80","443"]
    destination_addresses = ["*"]
    protocols             = ["TCP"]
  }
}

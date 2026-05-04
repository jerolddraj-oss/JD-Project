resource "azurerm_firewall" "fw" {
  name                = "jd-azfw"
  location            = var.location
  resource_group_name = var.rg
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = var.public_ip_id
  }
}

resource "azurerm_route_table" "rt" {
  name                = "jd-udr"
  location            = var.location
  resource_group_name = var.rg
}

resource "azurerm_route" "default" {
  name                   = "default-to-firewall"
  resource_group_name    = var.rg
  route_table_name       = azurerm_route_table.rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.fw.ip_configuration[0].private_ip_address
}

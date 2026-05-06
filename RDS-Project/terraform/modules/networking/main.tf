###################################################
# Hub Virtual Network
###################################################

resource "azurerm_virtual_network" "hub_vnet" {
  name                = var.hub_vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = var.hub_vnet_address_space

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# Spoke Virtual Network
###################################################

resource "azurerm_virtual_network" "spoke_vnet" {
  name                = var.spoke_vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name

  address_space = var.spoke_vnet_address_space

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# Hub Subnets
###################################################

resource "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name

  address_prefixes = [
    var.gateway_subnet_prefix
  ]
}

resource "azurerm_subnet" "management_subnet" {
  name                 = "ManagementSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name

  address_prefixes = [
    var.management_subnet_prefix
  ]
}

###################################################
# Spoke Subnet
###################################################

resource "azurerm_subnet" "sessionhost_subnet" {
  name                 = "SessionHostSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name

  address_prefixes = [
    var.sessionhost_subnet_prefix
  ]
}

###################################################
# Route Table
###################################################

resource "azurerm_route_table" "hub_route_table" {
  name                = "${var.project_name}-hub-rt"
  location            = var.location
  resource_group_name = var.resource_group_name

  disable_bgp_route_propagation = false

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# Route Table Association
###################################################

resource "azurerm_subnet_route_table_association" "management_subnet_assoc" {
  subnet_id      = azurerm_subnet.management_subnet.id
  route_table_id = azurerm_route_table.hub_route_table.id
}

resource "azurerm_subnet_route_table_association" "sessionhost_subnet_assoc" {
  subnet_id      = azurerm_subnet.sessionhost_subnet.id
  route_table_id = azurerm_route_table.hub_route_table.id
}
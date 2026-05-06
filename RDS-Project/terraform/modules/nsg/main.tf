###################################################
# Management NSG
###################################################

resource "azurerm_network_security_group" "management_nsg" {
  name                = "${var.project_name}-management-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# Session Host NSG
###################################################

resource "azurerm_network_security_group" "sessionhost_nsg" {
  name                = "${var.project_name}-sessionhost-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# Allow RDP Access
###################################################

resource "azurerm_network_security_rule" "allow_rdp_management" {
  name                        = "Allow-RDP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "3389"

  source_address_prefix       = var.allowed_management_ip
  destination_address_prefix  = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.management_nsg.name
}

###################################################
# Allow WinRM
###################################################

resource "azurerm_network_security_rule" "allow_winrm_http" {
  name                        = "Allow-WinRM-HTTP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "5985"

  source_address_prefix       = var.allowed_management_ip
  destination_address_prefix  = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.management_nsg.name
}

resource "azurerm_network_security_rule" "allow_winrm_https" {
  name                        = "Allow-WinRM-HTTPS"
  priority                    = 111
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "5986"

  source_address_prefix       = var.allowed_management_ip
  destination_address_prefix  = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.management_nsg.name
}

###################################################
# Allow HTTPS
###################################################

resource "azurerm_network_security_rule" "allow_https" {
  name                        = "Allow-HTTPS"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"

  source_port_range           = "*"
  destination_port_range      = "443"

  source_address_prefix       = "*"
  destination_address_prefix  = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.management_nsg.name
}

###################################################
# Internal RDS Communication
###################################################

resource "azurerm_network_security_rule" "allow_internal_sessionhost" {
  name                        = "Allow-Internal-RDS"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"

  source_port_range           = "*"
  destination_port_range      = "*"

  source_address_prefix       = var.spoke_vnet_address_space
  destination_address_prefix  = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.sessionhost_nsg.name
}

###################################################
# Associate Management NSG
###################################################

resource "azurerm_subnet_network_security_group_association" "management_assoc" {
  subnet_id                 = var.management_subnet_id
  network_security_group_id = azurerm_network_security_group.management_nsg.id
}

###################################################
# Associate Session Host NSG
###################################################

resource "azurerm_subnet_network_security_group_association" "sessionhost_assoc" {
  subnet_id                 = var.sessionhost_subnet_id
  network_security_group_id = azurerm_network_security_group.sessionhost_nsg.id
}

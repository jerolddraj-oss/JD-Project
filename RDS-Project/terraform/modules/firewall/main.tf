###################################################
# Azure Firewall Public IP
###################################################

resource "azurerm_public_ip" "firewall_pip" {
  name                = "${var.project_name}-firewall-pip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# Azure Firewall Policy
###################################################

resource "azurerm_firewall_policy" "fw_policy" {
  name                = "${var.project_name}-fw-policy"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku = "Standard"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# Azure Firewall
###################################################

resource "azurerm_firewall" "azure_firewall" {
  name                = "${var.project_name}-firewall"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "AZFW_VNet"
  sku_tier = "Standard"

  firewall_policy_id = azurerm_firewall_policy.fw_policy.id

  ip_configuration {
    name                 = "firewall-ipconfig"
    subnet_id            = var.gateway_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# Network Rule Collection
###################################################

resource "azurerm_firewall_policy_rule_collection_group" "network_rules" {
  name               = "network-rule-collection-group"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 100

  network_rule_collection {
    name     = "allow-rds-network-traffic"
    priority = 100
    action   = "Allow"

    rule {
      name = "allow-rdp"

      protocols = ["TCP"]

      source_addresses = [
        var.allowed_management_ip
      ]

      destination_ports = [
        "3389"
      ]

      destination_addresses = [
        "*"
      ]
    }

    rule {
      name = "allow-winrm"

      protocols = ["TCP"]

      source_addresses = [
        var.allowed_management_ip
      ]

      destination_ports = [
        "5985",
        "5986"
      ]

      destination_addresses = [
        "*"
      ]
    }
  }
}

###################################################
# Application Rule Collection
###################################################

resource "azurerm_firewall_policy_rule_collection_group" "application_rules" {
  name               = "application-rule-collection-group"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 200

  application_rule_collection {
    name     = "allow-windows-update"
    priority = 100
    action   = "Allow"

    rule {
      name = "windows-update-access"

      protocols {
        type = "Https"
        port = 443
      }

      source_addresses = [
        var.hub_vnet_address_space
      ]

      destination_fqdns = [
        "*.windowsupdate.com",
        "*.microsoft.com",
        "*.azure.com"
      ]
    }
  }
}
# Root Orchestration - Fixed for module compatibility

resource "azurerm_resource_group" "main" {
  name     = "jd-rg"
  location = var.location
}

# HUB
module "hub" {
  source = "./modules/hub"
}

# SPOKES
module "spoke1" {
  source = "./modules/spoke"
}

module "spoke2" {
  source = "./modules/spoke"
}

module "spoke3" {
  source = "./modules/spoke"
}

# VNET PEERING
module "vnet_peering" {
  source = "./modules/vnet-peering"

  depends_on = [
    module.hub,
    module.spoke1,
    module.spoke2,
    module.spoke3
  ]
}

# NETWORK SECURITY
module "network_security" {
  source = "./modules/network-security"

  depends_on = [module.hub]
}

# FIREWALL RULES
module "security" {
  source = "./modules/security"

  depends_on = [module.network_security]
}

# DNS
module "dns" {
  source = "./modules/dns"

  depends_on = [module.hub]
}

# AKS
module "aks" {
  source = "./modules/aks"

  depends_on = [module.spoke1]
}

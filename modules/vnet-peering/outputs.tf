output "peering_status" {
  value = {
    hub_to_spoke = {
      for k, v in azurerm_virtual_network_peering.hub_to_spoke :
      k => v.peering_state
    }
    spoke_to_hub = {
      for k, v in azurerm_virtual_network_peering.spoke_to_hub :
      k => v.peering_state
    }
  }
}

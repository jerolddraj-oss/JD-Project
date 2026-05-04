resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                = "vmss-spoke"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.vm_size
  instances           = var.instance_count
  admin_username      = var.admin_username
  zones               = ["1", "2"]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk { caching = "ReadWrite" storage_account_type = "Standard_LRS" }

  network_interface {
    name    = "vmssnic"
    primary = true
    ip_configuration {
      name      = "ipconfig"
      primary   = true
      subnet_id = var.subnet_id
      public_ip_address {
        name = "vmss-pip"
      }
    }
  }
  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "dc" {
  name                = "dc01"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B2ms"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [var.nic_id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}

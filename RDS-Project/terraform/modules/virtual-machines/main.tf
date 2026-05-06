  ###################################################
# Availability Set
###################################################

resource "azurerm_availability_set" "rds_avset" {
  name                         = "${var.project_name}-avset"
  location                     = var.location
  resource_group_name          = var.resource_group_name

  managed                      = true
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# RD Gateway NIC
###################################################

resource "azurerm_network_interface" "rd_gateway_nic" {
  name                = "${var.rd_gateway_vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.management_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.rd_gateway_private_ip
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# RD Broker NIC
###################################################

resource "azurerm_network_interface" "rd_broker_nic" {
  name                = "${var.rd_broker_vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.management_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.rd_broker_private_ip
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# Session Host NICs
###################################################

resource "azurerm_network_interface" "sessionhost_nic" {
  count               = var.rd_session_host_count

  name                = "rdsh-${count.index + 1}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.sessionhost_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.rd_gateway_private_ip
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# RD Gateway VM
###################################################

resource "azurerm_windows_virtual_machine" "rd_gateway_vm" {
  name                = var.rd_gateway_vm_name
  resource_group_name = var.resource_group_name
  location            = var.location

  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.rd_gateway_nic.id
  ]

  availability_set_id = azurerm_availability_set.rds_avset.id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  enable_automatic_updates = true
  provision_vm_agent       = true

  boot_diagnostics {}

  tags = {
    Role        = "RD-Gateway"
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# RD Broker VM
###################################################

resource "azurerm_windows_virtual_machine" "rd_broker_vm" {
  name                = var.rd_broker_vm_name
  resource_group_name = var.resource_group_name
  location            = var.location

  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.rd_broker_nic.id
  ]

  availability_set_id = azurerm_availability_set.rds_avset.id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  enable_automatic_updates = true
  provision_vm_agent       = true

  boot_diagnostics {}

  tags = {
    Role        = "RD-Broker"
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# RD Session Hosts
###################################################

resource "azurerm_windows_virtual_machine" "rd_session_host_vm" {
  count               = var.rd_session_host_count

  name                = "rdsh-${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location

  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.sessionhost_nic[count.index].id
  ]

  availability_set_id = azurerm_availability_set.rds_avset.id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  enable_automatic_updates = true
  provision_vm_agent       = true

  boot_diagnostics {}

  tags = {
    Role        = "RD-SessionHost"
    Environment = var.environment
    Project     = var.project_name
  }
}

###################################################
# WinRM Extension Configuration
###################################################

resource "azurerm_virtual_machine_extension" "enable_winrm" {
  count                = var.rd_session_host_count

  name                 = "enable-winrm-${count.index}"
  virtual_machine_id   = azurerm_windows_virtual_machine.rd_session_host_vm[count.index].id

  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
{
  "commandToExecute": "powershell -ExecutionPolicy Unrestricted Enable-PSRemoting -Force"
}
SETTINGS
}

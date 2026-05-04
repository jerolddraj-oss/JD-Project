variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "name" { type = string }
variable "instance_count" { type = number }
variable "vm_size" { type = string }
variable "subnet_id" { type = string }
variable "zones" { type = list(string) default = [] }
variable "tags" { type = map(string) }
variable "log_analytics_workspace_id" { type = string }

resource "random_string" "admin" {
  length  = 12
  special = false
}

resource "azurerm_public_ip" "vmss_pip" {
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.vm_size
  instances           = var.instance_count
  admin_username      = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key_path != "" ? var.ssh_public_key_path : "~/.ssh/id_rsa.pub")
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  network_interface {
    name    = "${var.name}-nic"
    primary = true
    ip_configuration {
      name                                   = "internal"
      subnet_id                              = var.subnet_id
      primary                                = true
      public_ip_address_configuration {
        name = "${var.name}-pip-config"
        idle_timeout_in_minutes = 10
        domain_name_label = "${replace(var.name, "_", "-")}-dns"
      }
    }
  }

  zones = var.zones

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  extension {
    name = "customScript"
    publisher = "Microsoft.Azure.Extensions"
    type = "CustomScript"
    type_handler_version = "2.0"
    settings = <<SETTINGS
      {
        "commandToExecute": "echo Hello from VMSS > /var/tmp/hello.txt"
      }
    SETTINGS
  }

  tags = var.tags
}

# VMSS public IP output (using the public IP resource)
output "public_ip" {
  value = azurerm_public_ip.vmss_pip.ip_address
}

output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.id
}

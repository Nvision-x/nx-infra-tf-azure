################################################################################
# Bastion VM (Jump Host)
# Azure equivalent of bastion-ec2.tf
################################################################################

################################################################################
# NSG for Bastion
################################################################################

resource "azurerm_network_security_group" "bastion" {
  count               = var.create && var.enable_bastion ? 1 : 0
  name                = "${var.bastion_vm_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # SSH access
  dynamic "security_rule" {
    for_each = length(var.bastion_allowed_ssh_cidrs) > 0 ? [1] : []
    content {
      name                       = "AllowSSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefixes    = var.bastion_allowed_ssh_cidrs
      destination_address_prefix = "*"
    }
  }

  # Deny all other inbound
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

################################################################################
# Public IP
################################################################################

resource "azurerm_public_ip" "bastion" {
  count               = var.create && var.enable_bastion ? 1 : 0
  name                = "${var.bastion_vm_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

################################################################################
# NIC
################################################################################

resource "azurerm_network_interface" "bastion" {
  count               = var.create && var.enable_bastion ? 1 : 0
  name                = "${var.bastion_vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.bastion_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion[0].id
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "bastion" {
  count                     = var.create && var.enable_bastion ? 1 : 0
  network_interface_id      = azurerm_network_interface.bastion[0].id
  network_security_group_id = azurerm_network_security_group.bastion[0].id
}

################################################################################
# SSH Key (generate if not provided)
################################################################################

resource "tls_private_key" "bastion" {
  count     = var.create && var.enable_bastion && var.bastion_ssh_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

################################################################################
# Bastion VM
################################################################################

resource "azurerm_linux_virtual_machine" "bastion" {
  count               = var.create && var.enable_bastion ? 1 : 0
  name                = var.bastion_vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.bastion_vm_size
  admin_username      = var.bastion_admin_username

  network_interface_ids = [azurerm_network_interface.bastion[0].id]

  admin_ssh_key {
    username   = var.bastion_admin_username
    public_key = var.bastion_ssh_public_key != "" ? var.bastion_ssh_public_key : tls_private_key.bastion[0].public_key_openssh
  }

  os_disk {
    name                 = "${var.bastion_vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.bastion_disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # User-assigned managed identity from nx-iam-tf-azure
  dynamic "identity" {
    for_each = var.bastion_identity_id != "" ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [var.bastion_identity_id]
    }
  }

  tags = merge(var.tags, {
    Name = var.bastion_vm_name
  })
}

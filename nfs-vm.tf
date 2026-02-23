################################################################################
# NFS VM (File Storage Server)
# Azure equivalent of nfs-ec2.tf
################################################################################

################################################################################
# NSG for NFS
################################################################################

resource "azurerm_network_security_group" "nfs" {
  count               = var.create && var.enable_nfs ? 1 : 0
  name                = "${var.nfs_vm_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # SSH access
  dynamic "security_rule" {
    for_each = length(var.nfs_allowed_cidrs) > 0 ? [1] : []
    content {
      name                       = "AllowSSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefixes    = var.nfs_allowed_cidrs
      destination_address_prefix = "*"
    }
  }

  # NFS access
  dynamic "security_rule" {
    for_each = length(var.nfs_allowed_cidrs) > 0 ? [1] : []
    content {
      name                       = "AllowNFS"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "2049"
      source_address_prefixes    = var.nfs_allowed_cidrs
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
# NIC (private only, no public IP)
################################################################################

resource "azurerm_network_interface" "nfs" {
  count               = var.create && var.enable_nfs ? 1 : 0
  name                = "${var.nfs_vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.nfs_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "nfs" {
  count                     = var.create && var.enable_nfs ? 1 : 0
  network_interface_id      = azurerm_network_interface.nfs[0].id
  network_security_group_id = azurerm_network_security_group.nfs[0].id
}

################################################################################
# SSH Key (generate if not provided)
################################################################################

resource "tls_private_key" "nfs" {
  count     = var.create && var.enable_nfs && var.nfs_ssh_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

################################################################################
# NFS VM
################################################################################

resource "azurerm_linux_virtual_machine" "nfs" {
  count               = var.create && var.enable_nfs ? 1 : 0
  name                = var.nfs_vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.nfs_vm_size
  admin_username      = var.nfs_admin_username

  network_interface_ids = [azurerm_network_interface.nfs[0].id]

  admin_ssh_key {
    username   = var.nfs_admin_username
    public_key = var.nfs_ssh_public_key != "" ? var.nfs_ssh_public_key : tls_private_key.nfs[0].public_key_openssh
  }

  os_disk {
    name                 = "${var.nfs_vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.nfs_disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  tags = merge(var.tags, {
    Name = var.nfs_vm_name
  })
}

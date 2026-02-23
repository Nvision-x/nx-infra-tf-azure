################################################################################
# Azure Key Vault + Secrets
# Azure equivalent of AWS Secrets Manager (secrets.tf)
################################################################################

data "azurerm_client_config" "current" {}

resource "random_id" "suffix" {
  count       = var.create ? 1 : 0
  byte_length = 4
}

################################################################################
# Key Vault
################################################################################

resource "azurerm_key_vault" "this" {
  count               = var.create ? 1 : 0
  name                = "nx-infra-${random_id.suffix[0].hex}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Allow the deploying identity to manage secrets
  rbac_authorization_enabled = true
  purge_protection_enabled  = false

  tags = var.tags
}

# Grant deployer access to manage secrets
resource "azurerm_role_assignment" "kv_secrets_officer" {
  count                = var.create ? 1 : 0
  scope                = azurerm_key_vault.this[0].id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

################################################################################
# Random Passwords
################################################################################

resource "random_password" "postgres" {
  count            = var.create && var.enable_postgres ? 1 : 0
  length           = 16
  special          = true
  override_special = "_#-=."
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

locals {
  postgres_password = var.enable_postgres ? (
    var.existing_postgres_password != "" ? var.existing_postgres_password : random_password.postgres[0].result
  ) : ""
}

################################################################################
# Key Vault Secrets
################################################################################

resource "azurerm_key_vault_secret" "postgres_password" {
  count        = var.create && var.enable_postgres ? 1 : 0
  name         = "postgres-admin-password"
  value        = local.postgres_password
  key_vault_id = azurerm_key_vault.this[0].id

  tags = {
    service = "postgresql"
  }

  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}

resource "azurerm_key_vault_secret" "bastion_ssh_private_key" {
  count        = var.create && var.enable_bastion && var.bastion_ssh_public_key == "" ? 1 : 0
  name         = "bastion-ssh-private-key"
  value        = tls_private_key.bastion[0].private_key_pem
  key_vault_id = azurerm_key_vault.this[0].id

  tags = {
    service = "bastion"
  }

  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}

resource "azurerm_key_vault_secret" "nfs_ssh_private_key" {
  count        = var.create && var.enable_nfs && var.nfs_ssh_public_key == "" ? 1 : 0
  name         = "nfs-ssh-private-key"
  value        = tls_private_key.nfs[0].private_key_pem
  key_vault_id = azurerm_key_vault.this[0].id

  tags = {
    service = "nfs"
  }

  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}

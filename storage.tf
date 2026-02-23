################################################################################
# Azure Storage Account + Blob Containers
# Azure equivalent of S3 buckets (s3.tf)
################################################################################

resource "random_id" "storage_suffix" {
  count       = var.create ? 1 : 0
  byte_length = 4
}

resource "azurerm_storage_account" "this" {
  count               = var.create ? 1 : 0
  name                = "nvisionx${random_id.storage_suffix[0].hex}"
  location            = var.location
  resource_group_name = var.resource_group_name

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Security: HTTPS only, TLS 1.2 minimum
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  # Blob versioning
  blob_properties {
    versioning_enabled = true
  }

  tags = merge(var.tags, {
    Name    = "nvisionx-storage"
    Purpose = "Application blob storage"
  })
}

################################################################################
# Blob Containers (equivalent to individual S3 buckets)
################################################################################

resource "azurerm_storage_container" "containers" {
  for_each              = var.create ? toset(var.storage_containers) : toset([])
  name                  = each.key
  storage_account_id    = azurerm_storage_account.this[0].id
  container_access_type = "private"
}

################################################################################
# Lifecycle Management (equivalent to S3 lifecycle rules)
################################################################################

resource "azurerm_storage_management_policy" "lifecycle" {
  count              = var.create && var.storage_lifecycle_days > 0 ? 1 : 0
  storage_account_id = azurerm_storage_account.this[0].id

  rule {
    name    = "expire-old-blobs"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.storage_lifecycle_days
      }
      snapshot {
        delete_after_days_since_creation_greater_than = var.storage_lifecycle_days
      }
    }
  }
}

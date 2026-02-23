################################################################################
# Azure Database for PostgreSQL Flexible Server
# Azure equivalent of RDS PostgreSQL (postgres.tf)
################################################################################

resource "azurerm_postgresql_flexible_server" "this" {
  count               = var.create && var.enable_postgres ? 1 : 0
  name                = var.postgres_server_name
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login    = var.postgres_admin_username
  administrator_password = local.postgres_password

  sku_name   = var.postgres_sku_name
  version    = var.postgres_version
  storage_mb = var.postgres_storage_mb

  # Private access via delegated subnet (equivalent to RDS subnet group)
  delegated_subnet_id = var.postgres_delegated_subnet_id != "" ? var.postgres_delegated_subnet_id : null
  private_dns_zone_id = var.postgres_private_dns_zone_id != "" ? var.postgres_private_dns_zone_id : null

  # Backup
  backup_retention_days        = var.postgres_backup_retention_days
  geo_redundant_backup_enabled = var.postgres_geo_redundant_backup

  # High Availability (disabled by default for cost)
  dynamic "high_availability" {
    for_each = var.postgres_high_availability ? [1] : []
    content {
      mode = "ZoneRedundant"
    }
  }

  # Maintenance window
  maintenance_window {
    day_of_week  = var.postgres_maintenance_day
    start_hour   = var.postgres_maintenance_hour
    start_minute = var.postgres_maintenance_minute
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone,
    ]
  }
}

################################################################################
# Database
################################################################################

resource "azurerm_postgresql_flexible_server_database" "this" {
  count     = var.create && var.enable_postgres ? 1 : 0
  name      = var.postgres_db_name
  server_id = azurerm_postgresql_flexible_server.this[0].id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

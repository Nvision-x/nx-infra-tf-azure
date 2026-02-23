################################################################################
# Azure AI Search
# Azure equivalent of OpenSearch (open-search.tf)
################################################################################

resource "azurerm_search_service" "this" {
  count               = var.create && var.enable_ai_search ? 1 : 0
  name                = var.ai_search_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.ai_search_sku

  replica_count  = var.ai_search_replica_count
  partition_count = var.ai_search_partition_count

  public_network_access_enabled = var.ai_search_public_access

  tags = var.tags
}

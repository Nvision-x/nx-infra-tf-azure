################################################################################
# Azure OpenAI - Kubernetes Service Accounts
# Azure equivalent of bedrock-service-accounts.tf
################################################################################

locals {
  openai_service_accounts_parsed = var.enable_openai_service_accounts ? {
    for sa in var.openai_service_accounts : sa => {
      namespace = split(":", sa)[0]
      name      = split(":", sa)[1]
    }
  } : {}
}

# Create namespaces for OpenAI service accounts if they don't exist
resource "kubernetes_namespace" "openai" {
  for_each = var.create && var.enable_openai_service_accounts && var.create_openai_namespaces ? toset([
    for sa in var.openai_service_accounts : split(":", sa)[0]
  ]) : toset([])

  metadata {
    name = each.value
    labels = {
      name                = each.value
      "managed-by"        = "terraform"
      "openai-access"     = "enabled"
      "app.kubernetes.io" = "openai-app"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
    ]
  }

  depends_on = [azurerm_kubernetes_cluster.this]
}

# Create Kubernetes ServiceAccounts for Azure OpenAI
resource "kubernetes_service_account" "openai" {
  for_each = var.create ? local.openai_service_accounts_parsed : {}

  metadata {
    name      = each.value.name
    namespace = each.value.namespace

    labels = {
      "app.kubernetes.io/name"       = each.value.name
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/component"  = "openai-access"
      "openai-enabled"               = "true"
    }
  }

  automount_service_account_token = true

  depends_on = [
    kubernetes_namespace.openai,
    azurerm_kubernetes_cluster.this,
  ]
}

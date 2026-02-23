################################################################################
# AKS Cluster Outputs
################################################################################

output "aks_cluster_id" {
  description = "The AKS cluster resource ID"
  value       = try(azurerm_kubernetes_cluster.this[0].id, null)
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = try(azurerm_kubernetes_cluster.this[0].name, null)
}

output "aks_cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = try(azurerm_kubernetes_cluster.this[0].fqdn, null)
}

output "aks_cluster_private_fqdn" {
  description = "The private FQDN of the AKS cluster (if private)"
  value       = try(azurerm_kubernetes_cluster.this[0].private_fqdn, null)
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL (feed this into nx-iam-tf-azure for federated credentials)"
  value       = try(azurerm_kubernetes_cluster.this[0].oidc_issuer_url, null)
}

output "aks_node_resource_group" {
  description = "The auto-generated node resource group name (MC_*)"
  value       = try(azurerm_kubernetes_cluster.this[0].node_resource_group, null)
}

output "aks_node_resource_group_id" {
  description = "The auto-generated node resource group ID"
  value       = try(azurerm_kubernetes_cluster.this[0].node_resource_group_id, null)
}

output "aks_kube_config_raw" {
  description = "Raw kubeconfig for the AKS cluster"
  value       = try(azurerm_kubernetes_cluster.this[0].kube_config_raw, null)
  sensitive   = true
}

output "aks_kube_config_host" {
  description = "Kubernetes API server host"
  value       = try(azurerm_kubernetes_cluster.this[0].kube_config[0].host, null)
}

output "aks_kube_config_ca_certificate" {
  description = "Base64-encoded CA certificate for the AKS cluster"
  value       = try(azurerm_kubernetes_cluster.this[0].kube_config[0].cluster_ca_certificate, null)
  sensitive   = true
}

output "aks_kube_config_client_certificate" {
  description = "Base64-encoded client certificate for AKS authentication"
  value       = try(azurerm_kubernetes_cluster.this[0].kube_config[0].client_certificate, null)
  sensitive   = true
}

output "aks_kube_config_client_key" {
  description = "Base64-encoded client key for AKS authentication"
  value       = try(azurerm_kubernetes_cluster.this[0].kube_config[0].client_key, null)
  sensitive   = true
}

################################################################################
# Storage Outputs
################################################################################

output "storage_account_name" {
  description = "Name of the Azure Storage Account"
  value       = try(azurerm_storage_account.this[0].name, null)
}

output "storage_account_id" {
  description = "ID of the Azure Storage Account"
  value       = try(azurerm_storage_account.this[0].id, null)
}

output "storage_account_primary_access_key" {
  description = "Primary access key for the storage account"
  value       = try(azurerm_storage_account.this[0].primary_access_key, null)
  sensitive   = true
}

output "storage_container_names" {
  description = "Map of blob container names"
  value       = { for k, v in azurerm_storage_container.containers : k => v.name }
}

################################################################################
# Key Vault Outputs
################################################################################

output "key_vault_id" {
  description = "ID of the Azure Key Vault"
  value       = try(azurerm_key_vault.this[0].id, null)
}

output "key_vault_uri" {
  description = "URI of the Azure Key Vault"
  value       = try(azurerm_key_vault.this[0].vault_uri, null)
}

################################################################################
# Bastion VM Outputs
################################################################################

output "bastion_public_ip" {
  description = "Public IP address of the bastion VM"
  value       = try(azurerm_public_ip.bastion[0].ip_address, null)
}

output "bastion_private_ip" {
  description = "Private IP address of the bastion VM"
  value       = try(azurerm_network_interface.bastion[0].private_ip_address, null)
}

output "bastion_private_key_pem" {
  description = "SSH private key for bastion (only if generated)"
  value       = var.enable_bastion && var.bastion_ssh_public_key == "" ? try(tls_private_key.bastion[0].private_key_pem, null) : null
  sensitive   = true
}

output "bastion_admin_username" {
  description = "Admin username for the bastion VM"
  value       = var.enable_bastion ? var.bastion_admin_username : null
}

################################################################################
# PostgreSQL Outputs
################################################################################

output "postgres_server_fqdn" {
  description = "FQDN of the PostgreSQL Flexible Server"
  value       = try(azurerm_postgresql_flexible_server.this[0].fqdn, null)
}

output "postgres_server_id" {
  description = "Resource ID of the PostgreSQL Flexible Server"
  value       = try(azurerm_postgresql_flexible_server.this[0].id, null)
}

output "postgres_admin_username" {
  description = "Administrator login for PostgreSQL"
  value       = var.enable_postgres ? var.postgres_admin_username : null
}

################################################################################
# AI Search Outputs
################################################################################

output "ai_search_id" {
  description = "Resource ID of the Azure AI Search service"
  value       = try(azurerm_search_service.this[0].id, null)
}

output "ai_search_endpoint" {
  description = "Endpoint URL of the Azure AI Search service"
  value       = var.enable_ai_search && var.create ? "https://${try(azurerm_search_service.this[0].name, "")}.search.windows.net" : null
}

output "ai_search_primary_key" {
  description = "Primary admin API key for AI Search"
  value       = try(azurerm_search_service.this[0].primary_key, null)
  sensitive   = true
}

################################################################################
# OpenAI Service Accounts Output
# NOTE: This output is intentionally excluded from the module outputs to avoid
# a provider cycle when the orchestrator configures the kubernetes provider
# from this module's AKS outputs. The K8s service accounts are still created;
# they just aren't exported as module outputs.
################################################################################

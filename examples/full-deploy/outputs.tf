output "aks_cluster_name" {
  description = "The AKS cluster name"
  value       = module.nx.aks_cluster_name
}

output "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL (for nx-iam-tf-azure federated credentials)"
  value       = module.nx.aks_oidc_issuer_url
}

output "aks_node_resource_group_id" {
  description = "AKS node resource group ID (for cluster autoscaler VMSS permissions)"
  value       = module.nx.aks_node_resource_group_id
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module.nx.storage_account_name
}

output "storage_account_id" {
  description = "Storage account ID (for nx-iam-tf-azure role assignments)"
  value       = module.nx.storage_account_id
}

output "bastion_public_ip" {
  description = "Bastion VM public IP"
  value       = module.nx.bastion_public_ip
}

output "bastion_private_key_pem" {
  description = "Bastion SSH private key"
  value       = module.nx.bastion_private_key_pem
  sensitive   = true
}

output "postgres_server_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = module.nx.postgres_server_fqdn
}

output "postgres_server_id" {
  description = "PostgreSQL server ID (for nx-iam-tf-azure Reader role)"
  value       = module.nx.postgres_server_id
}

output "ai_search_id" {
  description = "AI Search service ID"
  value       = module.nx.ai_search_id
}

output "ai_search_endpoint" {
  description = "AI Search endpoint URL"
  value       = module.nx.ai_search_endpoint
}

output "key_vault_id" {
  description = "Key Vault ID"
  value       = module.nx.key_vault_id
}

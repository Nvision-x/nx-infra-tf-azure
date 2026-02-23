location            = "eastus"
resource_group_name = "nx-aks-rg"

# AKS Cluster
cluster_name       = "aks-dev"
kubernetes_version = "1.30"

# Identity IDs (from nx-iam-tf-azure output)
cluster_identity_id           = ""
kubelet_identity_id           = ""
kubelet_identity_client_id    = ""
kubelet_identity_principal_id = ""

# Node Pool Subnet (from nx-networking-tf-azure output)
default_node_pool_subnet_id = ""

# Bastion
enable_bastion            = true
bastion_subnet_id         = ""
bastion_allowed_ssh_cidrs = []
bastion_identity_id       = ""

# NFS
enable_nfs    = false
nfs_subnet_id = ""

# PostgreSQL
enable_postgres              = true
postgres_server_name         = "nx-pg-dev"
postgres_sku_name            = "B_Standard_B1ms"
postgres_version             = "16"
postgres_storage_mb          = 32768
postgres_db_name             = "nvisionx"
postgres_delegated_subnet_id = ""
postgres_private_dns_zone_id = ""

# AI Search
enable_ai_search = false
ai_search_name   = "nx-search-dev"
ai_search_sku    = "basic"

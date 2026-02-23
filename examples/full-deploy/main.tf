module "nx" {
  # source = "git::https://github.com/Nvision-x/nx-infra-tf-azure.git"
  source = "../.."

  # --------------------- Global ---------------------

  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  docker_hub_username = var.docker_hub_username
  docker_hub_token    = var.docker_hub_token
  github_cr_username  = var.github_cr_username
  github_cr_token     = var.github_cr_token

  # --------------------- AKS ---------------------

  cluster_name      = var.cluster_name
  kubernetes_version = var.kubernetes_version

  cluster_identity_id           = var.cluster_identity_id
  kubelet_identity_id           = var.kubelet_identity_id
  kubelet_identity_client_id    = var.kubelet_identity_client_id
  kubelet_identity_principal_id = var.kubelet_identity_principal_id

  private_cluster_enabled         = var.private_cluster_enabled
  api_server_authorized_ip_ranges = var.api_server_authorized_ip_ranges

  default_node_pool_vm_size             = var.default_node_pool_vm_size
  default_node_pool_node_count          = var.default_node_pool_node_count
  default_node_pool_min_count           = var.default_node_pool_min_count
  default_node_pool_max_count           = var.default_node_pool_max_count
  default_node_pool_enable_auto_scaling = var.default_node_pool_enable_auto_scaling
  default_node_pool_subnet_id           = var.default_node_pool_subnet_id
  additional_node_pools                 = var.additional_node_pools

  # --------------------- PostgreSQL ---------------------

  enable_postgres              = var.enable_postgres
  postgres_server_name         = var.postgres_server_name
  postgres_sku_name            = var.postgres_sku_name
  postgres_version             = var.postgres_version
  postgres_storage_mb          = var.postgres_storage_mb
  postgres_db_name             = var.postgres_db_name
  postgres_admin_username      = var.postgres_admin_username
  postgres_delegated_subnet_id = var.postgres_delegated_subnet_id
  postgres_private_dns_zone_id = var.postgres_private_dns_zone_id

  # --------------------- AI Search ---------------------

  enable_ai_search   = var.enable_ai_search
  ai_search_name     = var.ai_search_name
  ai_search_sku      = var.ai_search_sku

  # --------------------- NFS ---------------------

  enable_nfs       = var.enable_nfs
  nfs_vm_name      = var.nfs_vm_name
  nfs_vm_size      = var.nfs_vm_size
  nfs_disk_size_gb = var.nfs_disk_size_gb
  nfs_subnet_id    = var.nfs_subnet_id
  nfs_allowed_cidrs = var.nfs_allowed_cidrs

  # --------------------- Bastion ---------------------

  enable_bastion            = var.enable_bastion
  bastion_vm_name           = var.bastion_vm_name
  bastion_vm_size           = var.bastion_vm_size
  bastion_subnet_id         = var.bastion_subnet_id
  bastion_allowed_ssh_cidrs = var.bastion_allowed_ssh_cidrs
  bastion_identity_id       = var.bastion_identity_id
}

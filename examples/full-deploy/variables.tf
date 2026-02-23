# ------------------------ Global ------------------------

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default = {
    Project = "nx-app"
  }
}

variable "docker_hub_username" {
  type    = string
  default = ""
}

variable "docker_hub_token" {
  type      = string
  default   = ""
  sensitive = true
}

variable "github_cr_username" {
  type    = string
  default = ""
}

variable "github_cr_token" {
  type      = string
  default   = ""
  sensitive = true
}

# ----------------------------- AKS --------------------------------------

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "cluster_identity_id" {
  description = "Cluster managed identity ID (from nx-iam-tf-azure)"
  type        = string
}

variable "kubelet_identity_id" {
  description = "Kubelet managed identity ID (from nx-iam-tf-azure)"
  type        = string
}

variable "kubelet_identity_client_id" {
  description = "Kubelet managed identity client ID (from nx-iam-tf-azure)"
  type        = string
}

variable "kubelet_identity_principal_id" {
  description = "Kubelet managed identity principal ID (from nx-iam-tf-azure)"
  type        = string
}

variable "private_cluster_enabled" {
  type    = bool
  default = false
}

variable "api_server_authorized_ip_ranges" {
  type    = list(string)
  default = []
}

variable "default_node_pool_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "default_node_pool_node_count" {
  type    = number
  default = 2
}

variable "default_node_pool_min_count" {
  type    = number
  default = 1
}

variable "default_node_pool_max_count" {
  type    = number
  default = 5
}

variable "default_node_pool_enable_auto_scaling" {
  type    = bool
  default = true
}

variable "default_node_pool_subnet_id" {
  description = "Subnet ID for the default AKS node pool"
  type        = string
}

variable "additional_node_pools" {
  type    = any
  default = {}
}

# ----------------------------- Bastion ---------------------

variable "enable_bastion" {
  type    = bool
  default = false
}

variable "bastion_vm_name" {
  type    = string
  default = "nx-bastion-host"
}

variable "bastion_vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "bastion_subnet_id" {
  type    = string
  default = ""
}

variable "bastion_allowed_ssh_cidrs" {
  type    = list(string)
  default = []
}

variable "bastion_identity_id" {
  type    = string
  default = ""
}

# ----------------------------- PostgreSQL ---------------------

variable "enable_postgres" {
  type    = bool
  default = false
}

variable "postgres_server_name" {
  type    = string
  default = ""
}

variable "postgres_sku_name" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "postgres_version" {
  type    = string
  default = "16"
}

variable "postgres_storage_mb" {
  type    = number
  default = 32768
}

variable "postgres_db_name" {
  type    = string
  default = "nvisionx"
}

variable "postgres_admin_username" {
  type    = string
  default = "pgadmin"
}

variable "postgres_delegated_subnet_id" {
  type    = string
  default = ""
}

variable "postgres_private_dns_zone_id" {
  type    = string
  default = ""
}

# ----------------------------- AI Search ---------------------

variable "enable_ai_search" {
  type    = bool
  default = false
}

variable "ai_search_name" {
  type    = string
  default = ""
}

variable "ai_search_sku" {
  type    = string
  default = "basic"
}

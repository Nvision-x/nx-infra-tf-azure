# variables.tf

variable "create" {
  description = "Master flag for creating resources"
  type        = bool
  default     = true
}

variable "location" {
  description = "Azure region (e.g., eastus)"
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Project = "nx-app"
  }
}

################################################################################
# Registry Credentials
################################################################################

variable "docker_hub_username" {
  description = "Docker Hub username"
  type        = string
  default     = ""
}

variable "docker_hub_token" {
  description = "Docker Hub read-only access token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_cr_username" {
  description = "GitHub Container Registry username"
  type        = string
  default     = ""
}

variable "github_cr_token" {
  description = "GitHub Container Registry personal access token"
  type        = string
  default     = ""
  sensitive   = true
}

################################################################################
# AKS Cluster
################################################################################

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
}

variable "cluster_identity_id" {
  description = "User-assigned managed identity ID for AKS cluster (from nx-iam-tf-azure)"
  type        = string
}

variable "kubelet_identity_id" {
  description = "User-assigned managed identity ID for AKS kubelet (from nx-iam-tf-azure)"
  type        = string
}

variable "kubelet_identity_client_id" {
  description = "Client ID of the kubelet managed identity (from nx-iam-tf-azure)"
  type        = string
}

variable "kubelet_identity_principal_id" {
  description = "Principal (object) ID of the kubelet managed identity (from nx-iam-tf-azure)"
  type        = string
}

variable "private_cluster_enabled" {
  description = "Enable private AKS cluster (API server not publicly accessible)"
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "Private DNS Zone ID for private AKS cluster"
  type        = string
  default     = null
}

variable "api_server_authorized_ip_ranges" {
  description = "List of CIDR blocks allowed to access the AKS API server (only for public clusters)"
  type        = list(string)
  default     = []
}

variable "sku_tier" {
  description = "AKS SKU tier: Free, Standard, or Premium"
  type        = string
  default     = "Free"
}

variable "support_plan" {
  description = "AKS support plan: KubernetesOfficial or AKSLongTermSupport"
  type        = string
  default     = "KubernetesOfficial"
}

variable "automatic_upgrade_channel" {
  description = "Automatic upgrade channel: none, patch, rapid, stable, node-image"
  type        = string
  default     = "patch"
}

variable "local_account_disabled" {
  description = "Disable local Kubernetes accounts (require Azure AD auth only)"
  type        = bool
  default     = false
}

################################################################################
# AKS Networking
################################################################################

variable "network_plugin" {
  description = "Network plugin: azure or kubenet"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy: azure or calico"
  type        = string
  default     = "azure"
}

variable "service_cidr" {
  description = "Kubernetes service CIDR range"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP within service_cidr"
  type        = string
  default     = "10.0.0.10"
}

################################################################################
# AKS Default Node Pool
################################################################################

variable "default_node_pool_name" {
  description = "Name for the default (system) node pool"
  type        = string
  default     = "system"
}

variable "default_node_pool_vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "default_node_pool_node_count" {
  description = "Initial node count for the default node pool"
  type        = number
  default     = 2
}

variable "default_node_pool_min_count" {
  description = "Minimum node count for autoscaling"
  type        = number
  default     = 1
}

variable "default_node_pool_max_count" {
  description = "Maximum node count for autoscaling"
  type        = number
  default     = 5
}

variable "default_node_pool_enable_auto_scaling" {
  description = "Enable autoscaling on the default node pool"
  type        = bool
  default     = true
}

variable "default_node_pool_os_disk_size_gb" {
  description = "OS disk size in GB for default node pool"
  type        = number
  default     = 50
}

variable "default_node_pool_subnet_id" {
  description = "Subnet ID for the default node pool"
  type        = string
}

variable "default_node_pool_zones" {
  description = "Availability zones for the default node pool"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "default_node_pool_max_pods" {
  description = "Maximum number of pods per node in the default pool"
  type        = number
  default     = 30
}

################################################################################
# AKS Additional Node Pools
################################################################################

variable "additional_node_pools" {
  description = "Map of additional node pool configurations"
  type = map(object({
    vm_size             = string
    node_count          = optional(number, 1)
    min_count           = optional(number, 1)
    max_count           = optional(number, 3)
    enable_auto_scaling = optional(bool, true)
    os_disk_size_gb     = optional(number, 50)
    zones               = optional(list(string), ["1", "2", "3"])
    subnet_id           = optional(string, "")
    node_labels         = optional(map(string), {})
    node_taints         = optional(list(string), [])
    max_pods            = optional(number, 30)
    mode                = optional(string, "User")
  }))
  default = {}
}

################################################################################
# Storage
################################################################################

variable "storage_containers" {
  description = "List of blob container names to create"
  type        = list(string)
  default     = ["logs", "minio", "companylogo", "csvfiles", "applogo", "os-backup", "postgres-backup"]
}

variable "storage_lifecycle_days" {
  description = "Days before blob expiration (0 to disable)"
  type        = number
  default     = 180
}

################################################################################
# Bastion VM
################################################################################

variable "enable_bastion" {
  description = "Enable bastion VM for cluster access"
  type        = bool
  default     = false
}

variable "bastion_vm_name" {
  description = "Name for the bastion VM"
  type        = string
  default     = "nx-bastion-host"
}

variable "bastion_vm_size" {
  description = "VM size for bastion"
  type        = string
  default     = "Standard_B2s"
}

variable "bastion_disk_size_gb" {
  description = "OS disk size in GB for bastion"
  type        = number
  default     = 30
}

variable "bastion_subnet_id" {
  description = "Subnet ID for the bastion VM (public subnet)"
  type        = string
  default     = ""
}

variable "bastion_admin_username" {
  description = "Admin username for the bastion VM"
  type        = string
  default     = "azureuser"
}

variable "bastion_ssh_public_key" {
  description = "Existing SSH public key for bastion (if empty, a key pair is generated)"
  type        = string
  default     = ""
}

variable "bastion_allowed_ssh_cidrs" {
  description = "CIDR blocks allowed SSH access to bastion VM"
  type        = list(string)
  default     = []
}

variable "bastion_identity_id" {
  description = "User-assigned managed identity ID for the bastion VM (from nx-iam-tf-azure)"
  type        = string
  default     = ""
}

################################################################################
# PostgreSQL Flexible Server
################################################################################

variable "enable_postgres" {
  description = "Enable Azure Database for PostgreSQL Flexible Server"
  type        = bool
  default     = false
}

variable "postgres_server_name" {
  description = "Name for the PostgreSQL server"
  type        = string
  default     = ""
}

variable "postgres_sku_name" {
  description = "SKU name for PostgreSQL (e.g., B_Standard_B1ms, GP_Standard_D2s_v3)"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "16"
}

variable "postgres_storage_mb" {
  description = "Storage size in MB for PostgreSQL"
  type        = number
  default     = 32768
}

variable "postgres_storage_tier" {
  description = "Storage tier for PostgreSQL (P4, P6, P10, P15, P20, P30, P40, P50, P60, P70, P80)"
  type        = string
  default     = "P4"
}

variable "postgres_db_name" {
  description = "Name of the initial database"
  type        = string
  default     = "nvisionx"
}

variable "postgres_admin_username" {
  description = "Administrator login for PostgreSQL"
  type        = string
  default     = "pgadmin"
}

variable "existing_postgres_password" {
  description = "Existing PostgreSQL password (if empty, one is generated)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "postgres_delegated_subnet_id" {
  description = "Delegated subnet ID for PostgreSQL private access"
  type        = string
  default     = ""
}

variable "postgres_private_dns_zone_id" {
  description = "Private DNS Zone ID for PostgreSQL (required for VNet integration)"
  type        = string
  default     = ""
}

variable "postgres_backup_retention_days" {
  description = "Backup retention days for PostgreSQL (7-35)"
  type        = number
  default     = 7
}

variable "postgres_geo_redundant_backup" {
  description = "Enable geo-redundant backup for PostgreSQL"
  type        = bool
  default     = false
}

variable "postgres_high_availability" {
  description = "Enable high availability for PostgreSQL (ZoneRedundant)"
  type        = bool
  default     = false
}

variable "postgres_maintenance_day" {
  description = "Preferred maintenance day (0=Sunday, 6=Saturday)"
  type        = number
  default     = 1
}

variable "postgres_maintenance_hour" {
  description = "Preferred maintenance hour (0-23)"
  type        = number
  default     = 0
}

variable "postgres_maintenance_minute" {
  description = "Preferred maintenance minute (0-59)"
  type        = number
  default     = 0
}

################################################################################
# Azure AI Search (OpenSearch equivalent)
################################################################################

variable "enable_ai_search" {
  description = "Enable Azure AI Search service"
  type        = bool
  default     = false
}

variable "ai_search_name" {
  description = "Name for the Azure AI Search service (must be globally unique)"
  type        = string
  default     = ""
}

variable "ai_search_sku" {
  description = "SKU for AI Search: free, basic, standard, standard2, standard3"
  type        = string
  default     = "basic"
}

variable "ai_search_replica_count" {
  description = "Number of replicas for AI Search"
  type        = number
  default     = 1
}

variable "ai_search_partition_count" {
  description = "Number of partitions for AI Search"
  type        = number
  default     = 1
}

variable "ai_search_public_access" {
  description = "Enable public network access for AI Search"
  type        = bool
  default     = true
}

################################################################################
# Elastic Cloud (Elasticsearch)
################################################################################

variable "elasticsearch_endpoint" {
  description = "Elastic Cloud Elasticsearch endpoint URL"
  type        = string
  default     = ""
}

variable "elasticsearch_username" {
  description = "Elastic Cloud username"
  type        = string
  default     = ""
}

variable "elasticsearch_password" {
  description = "Elastic Cloud password"
  type        = string
  default     = ""
  sensitive   = true
}

################################################################################
# Azure OpenAI Service Accounts (Bedrock equivalent)
################################################################################

variable "enable_openai_service_accounts" {
  description = "Enable creation of Kubernetes ServiceAccounts for Azure OpenAI access"
  type        = bool
  default     = false
}

variable "openai_service_accounts" {
  description = "List of namespace:serviceaccount pairs for OpenAI access. Example: [\"default:ai-app\", \"production:ai-service\"]"
  type        = list(string)
  default     = []
}

variable "create_openai_namespaces" {
  description = "Whether to create namespaces for OpenAI service accounts if they don't exist"
  type        = bool
  default     = false
}

################################################################################
# Ingress Configuration
################################################################################

variable "ingress_type" {
  description = "Ingress type: internet-facing or internal"
  type        = string
  default     = null
  validation {
    condition     = var.ingress_type == null || contains(["internet-facing", "internal"], var.ingress_type)
    error_message = "Must be either null, 'internet-facing', or 'internal'."
  }
}

variable "ingress_host" {
  description = "Hostname (FQDN) for ingress"
  type        = string
  default     = null
}

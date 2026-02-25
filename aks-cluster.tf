################################################################################
# AKS Cluster
# Azure equivalent of EKS cluster (eks-cluster.tf)
################################################################################

resource "azurerm_kubernetes_cluster" "this" {
  count               = var.create ? 1 : 0
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier
  support_plan        = var.support_plan

  # User-assigned identity from nx-iam-tf-azure
  identity {
    type         = "UserAssigned"
    identity_ids = [var.cluster_identity_id]
  }

  kubelet_identity {
    client_id                 = var.kubelet_identity_client_id
    object_id                 = var.kubelet_identity_principal_id
    user_assigned_identity_id = var.kubelet_identity_id
  }

  # Networking
  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    load_balancer_sku = "standard"
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
  }

  # Default system node pool
  default_node_pool {
    name                 = var.default_node_pool_name
    vm_size              = var.default_node_pool_vm_size
    node_count           = var.default_node_pool_enable_auto_scaling ? null : var.default_node_pool_node_count
    min_count            = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_min_count : null
    max_count            = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_max_count : null
    auto_scaling_enabled = var.default_node_pool_enable_auto_scaling
    os_disk_size_gb      = var.default_node_pool_os_disk_size_gb
    vnet_subnet_id       = var.default_node_pool_subnet_id
    zones                = var.default_node_pool_zones
    max_pods             = var.default_node_pool_max_pods
  }

  # Workload Identity + OIDC (equivalent to Pod Identity Agent in EKS)
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Private cluster settings
  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id     = var.private_cluster_enabled ? var.private_dns_zone_id : null

  # API server access
  dynamic "api_server_access_profile" {
    for_each = length(var.api_server_authorized_ip_ranges) > 0 && !var.private_cluster_enabled ? [1] : []
    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  # Azure AD RBAC
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
  }

  # Upgrade channel
  automatic_upgrade_channel = var.automatic_upgrade_channel

  # Local accounts
  local_account_disabled = var.local_account_disabled

  tags = var.tags
}

################################################################################
# Additional Node Pools
################################################################################

resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = var.create ? var.additional_node_pools : {}

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this[0].id
  vm_size               = each.value.vm_size
  node_count            = each.value.enable_auto_scaling ? null : each.value.node_count
  min_count             = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count             = each.value.enable_auto_scaling ? each.value.max_count : null
  auto_scaling_enabled  = each.value.enable_auto_scaling
  os_disk_size_gb       = each.value.os_disk_size_gb
  vnet_subnet_id        = each.value.subnet_id != "" ? each.value.subnet_id : var.default_node_pool_subnet_id
  zones                 = each.value.zones
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints
  max_pods              = each.value.max_pods
  mode                  = each.value.mode

  tags = var.tags
}

################################################################################
# Kubernetes ConfigMap - Infrastructure Configuration
# Equivalent to kubernetes_config_map "infra_config" in AWS
################################################################################

locals {
  pg_host     = var.enable_postgres && var.create ? azurerm_postgresql_flexible_server.this[0].fqdn : null
  pg_username = var.enable_postgres ? var.postgres_admin_username : null

  ai_search_endpoint = var.enable_ai_search && var.create ? "https://${azurerm_search_service.this[0].name}.search.windows.net" : null
}

resource "kubernetes_config_map" "infra_config" {
  count = var.create ? 1 : 0

  metadata {
    name      = "infra-config"
    namespace = "default"
  }

  data = merge(
    {
      STORAGE_ACCOUNT_NAME = azurerm_storage_account.this[0].name
      STORAGE_CONTAINER_LOGS        = "logs"
      STORAGE_CONTAINER_MINIO       = "minio"
      STORAGE_CONTAINER_COMPANYLOGO = "companylogo"
      STORAGE_CONTAINER_CSVFILES    = "csvfiles"
      STORAGE_CONTAINER_APPLOGO     = "applogo"
    },

    # PostgreSQL config (only when enabled)
    { for k, v in {
      POSTGRES_HOST     = local.pg_host
      POSTGRES_USERNAME = local.pg_username
    } : k => v if v != null },

    # AI Search config (only when enabled)
    { for k, v in {
      AI_SEARCH_ENDPOINT = local.ai_search_endpoint
    } : k => v if v != null },

    # Elastic Cloud config (only when endpoint provided)
    { for k, v in {
      ELASTICSEARCH_HOST       = var.elasticsearch_endpoint
      ELASTICSEARCH_PORT       = "443"
      ELASTICSEARCH_USE_SSL    = "true"
      ELASTICSEARCH_SECURED    = "true"
      ELASTICSEARCH_VERIFY_CERTS = "true"
      ELASTICSEARCH_USE_OPENSEARCH = "true"
      ELASTICSEARCH_USERNAME   = var.elasticsearch_username
      OPENSEARCH_URL           = var.elasticsearch_endpoint
    } : k => v if var.elasticsearch_endpoint != "" },

    # Ingress settings
    var.ingress_type != null ? { ingress-type = var.ingress_type } : {},
    var.ingress_host != null ? { ingress-host = var.ingress_host } : {},
    { azure-region = var.location }
  )

  depends_on = [azurerm_kubernetes_cluster.this]
}

################################################################################
# Kubernetes Secrets
################################################################################

resource "kubernetes_secret" "infra_secrets" {
  count = var.create && (var.enable_postgres || var.elasticsearch_password != "") ? 1 : 0

  metadata {
    name      = "infra-secrets"
    namespace = "default"
  }
  data = merge(
    {
      POSTGRES_PASSWORD = local.postgres_password
    },
    var.enable_ai_search ? {
      AI_SEARCH_ADMIN_KEY = azurerm_search_service.this[0].primary_key
    } : {},
    var.elasticsearch_password != "" ? {
      ELASTICSEARCH_PASSWORD = var.elasticsearch_password
    } : {}
  )
  type = "Opaque"

  depends_on = [azurerm_kubernetes_cluster.this]
}

################################################################################
# Registry Pull Secrets
################################################################################

locals {
  docker_auth_b64    = base64encode("${trimspace(var.docker_hub_username)}:${trimspace(var.docker_hub_token)}")
  github_cr_auth_b64 = base64encode("${trimspace(var.github_cr_username)}:${trimspace(var.github_cr_token)}")

  dockerconfigjson = jsonencode({
    auths = {
      "https://index.docker.io/v1/" = {
        auth     = local.docker_auth_b64
        username = trimspace(var.docker_hub_username)
        password = trimspace(var.docker_hub_token)
      }
    }
  })

  githubcrconfigjson = jsonencode({
    auths = {
      "ghcr.io" = {
        auth     = local.github_cr_auth_b64
        username = trimspace(var.github_cr_username)
        password = trimspace(var.github_cr_token)
      }
    }
  })
}

resource "kubernetes_secret" "docker_hub" {
  count = var.create && length(trimspace(var.docker_hub_username)) > 0 && length(trimspace(var.docker_hub_token)) > 0 ? 1 : 0

  metadata {
    name      = "docker-hub-secret"
    namespace = "default"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = local.dockerconfigjson
  }

  depends_on = [azurerm_kubernetes_cluster.this]
}

resource "kubernetes_secret" "github_cr" {
  count = var.create && length(trimspace(var.github_cr_username)) > 0 && length(trimspace(var.github_cr_token)) > 0 ? 1 : 0

  metadata {
    name      = "github-cr-secret"
    namespace = "default"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = local.githubcrconfigjson
  }

  depends_on = [azurerm_kubernetes_cluster.this]
}

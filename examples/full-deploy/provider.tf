# Backend configuration (uncomment and configure for your environment)
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraform-state-rg"
#     storage_account_name = "tfstateXXXXXXXX"
#     container_name       = "tfstate"
#     key                  = "nx-infra.tfstate"
#   }
# }

terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Kubernetes provider - configured from AKS cluster output
provider "kubernetes" {
  host                   = module.nx.aks_kube_config_host
  cluster_ca_certificate = base64decode(module.nx.aks_kube_config_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--login", "azurecli",
      "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630",
    ]
  }
}

# Helm provider
provider "helm" {
  kubernetes {
    host                   = module.nx.aks_kube_config_host
    cluster_ca_certificate = base64decode(module.nx.aks_kube_config_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "kubelogin"
      args = [
        "get-token",
        "--login", "azurecli",
        "--server-id", "6dae42f8-4368-4678-94ff-3960e28e3630",
      ]
    }
  }
}

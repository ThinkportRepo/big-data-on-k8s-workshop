

terraform {
  backend "local" { }
  required_providers {
      kubernetes = {
        source  = "hashicorp/kubernetes"
        version = ">= 2.0.3"
      }
      azurerm = {
        source  = "hashicorp/azurerm"
        version = ">=2.42, < 4.0 "
      }
      helm = {
        source  = "hashicorp/helm"
        version = ">= 2.1.0"
      }
  }
}
provider "azurerm" {
  features {}
}

data "azurerm_kubernetes_cluster" "this" {
  depends_on          = [module.aks] # refresh cluster state before reading
  name                = module.aks.kubernetes_cluster_name
  resource_group_name = module.aks.resource_group_name
}
provider "azurerm" {
  features {
    
  }
  skip_provider_registration = true
  alias = "prod"  
  subscription_id = var.AZ_Subscription_ID
}
provider "azurerm" {
  features {
    
  }
  skip_provider_registration = true
  alias = "SA"
  subscription_id = var.AZ_Subscription_ID
  client_id = data.azurerm_key_vault_secret.cred_secret["client-id"].value
  client_secret = data.azurerm_key_vault_secret.cred_secret["client-secret"].value
  tenant_id = data.azurerm_key_vault_secret.cred_secret["tenant-id"].value
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.this.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.this.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate)
  }
}
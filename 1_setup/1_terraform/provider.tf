

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
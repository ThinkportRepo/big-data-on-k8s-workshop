module "aks" {
  #count = var.NumberOfClusters
  source                    = "./modules/aks"
  UniquePrefix = local.UniquePrefix
  SharedPrefix = var.SharedPrefix
  ResourceGroupName = var.ResourceGroupName
  Location = var.Location
  NodeSize = var.NodeSize
  NodeCount = var.NodeCount
  NodeDiskSize = var.NodeDiskSize
  HttpApplicationRouting = var.HttpApplicationRouting
  NetworkPlugin = var.NetworkPlugin
  NetworkPolicy = var.NetworkPolicy
  }

resource "local_file" "kube_config" {
  #  count = var.NumberOfClusters
    filename = "./${local.UniquePrefix}.config"
    content = module.aks.kube_config
} 

module "kubernetes-config" {
  depends_on   = [module.aks]
  source       = "./modules/kubernetes-config"
  ClusterName = module.aks.kubernetes_cluster_name
  UserName = local.UniquePrefix
  kubeconfig   = data.azurerm_kubernetes_cluster.this.kube_config_raw
  #TlsCertificate = file("k8s-${var.CloudFlareDNS}.pem")
  #TlsKey = file("k8s-${var.CloudFlareDNS}.key")
  #ClusterDNS = "${local.UniquePrefix}.k8s.${var.CloudFlareDNS}"
  ClusterDNS = module.aks.dns_zone
  #CloudFlareDNSZoneID = var.CloudFlareDNSZoneID
  #CloudFlareToken = var.CloudFlareToken
  GitHubUsername = var.GitHubUsername
  GitHubRepoToken = var.GitHubRepoToken
#  GitHubPackagesToken = var.GitHubPackagesToken
  DockerhubUser = var.DockerhubUser
  DockerhubPAT = var.DockerhubPAT
}

resource "local_file" "dns_zone" {
    filename = "./${local.UniquePrefix}-dns.txt"
    content = module.aks.dns_zone
} 

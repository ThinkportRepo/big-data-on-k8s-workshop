module "aks" {
  count = var.NumberOfClusters
  source                    = "./modules/aks"
  ClusterNumber = count.index
  SharedPrefix = var.SharedPrefix
  ResourceGroupName = var.ResourceGroupName
  Location = var.Location
  NodeSize = var.NodeSize
  NodeCount = var.NodeCount
  HttpApplicationRouting = var.HttpApplicationRouting
  NetworkPlugin = var.NetworkPlugin
  NetworkPolicy = var.NetworkPolicy
  }

resource "local_file" "kube_config" {
    count = var.NumberOfClusters
    filename = "./${module.aks[count.index].random_pet}.config"
    content = module.aks[count.index].kube_config
} 
resource "local_file" "dns_zone" {
    count = var.NumberOfClusters
    filename = "./${module.aks[count.index].random_pet}-dns.txt"
    content = module.aks[count.index].dns_zone
} 
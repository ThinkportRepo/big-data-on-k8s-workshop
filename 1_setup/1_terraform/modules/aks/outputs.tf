output "resource_group_name" {
  value = var.ResourceGroupName #azurerm_resource_group.aks.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

# output "host" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.host
# }

# output "client_key" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.client_key
# }

# output "client_certificate" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.client_certificate
# }

 output "kube_config" {
   value = azurerm_kubernetes_cluster.aks.kube_config_raw
 }

# output "cluster_username" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.username
# }

# output "cluster_password" {
#   value = azurerm_kubernetes_cluster.default.kube_config.0.password
# }
#output "random_pet" {
#  value = random_pet.prefix.id
#}
output "dns_zone" {
  value = var.HttpApplicationRouting == true ? azurerm_kubernetes_cluster.aks.http_application_routing_zone_name : ""
}
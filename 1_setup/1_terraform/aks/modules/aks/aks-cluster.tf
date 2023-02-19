#resource "random_pet" "prefix" {}

#resource "azurerm_resource_group" "default" {
#  name     = "${random_pet.prefix.id}-rg"
#  location = "West US 2"
#
#  tags = {
#    environment = "Demo"
#  }
#}

resource "azurerm_kubernetes_cluster" "aks"{
  name                = "${var.SharedPrefix}-${var.UniquePrefix}-aks"
  location            = var.Location
  resource_group_name = var.ResourceGroupName
  dns_prefix          = "${var.UniquePrefix}"
  http_application_routing_enabled = var.HttpApplicationRouting
  network_profile {
    network_plugin = var.NetworkPlugin
    network_policy = var.NetworkPolicy
  }
  default_node_pool {
    name            = "default"
    node_count      = var.NodeCount
    vm_size         = var.NodeSize
    os_disk_size_gb = var.NodeDiskSize
    os_disk_type = "Managed"
    kubelet_disk_type = "OS"
    os_sku = "Ubuntu"
  }

  identity {
    type = "SystemAssigned"
  }
 # service_principal {
 #   client_id     = var.appId
 #   client_secret = var.password
 # }

#  tags = {
#    environment = "Demo"
#  }
}

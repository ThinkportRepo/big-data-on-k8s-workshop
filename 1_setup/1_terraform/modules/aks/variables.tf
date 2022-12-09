variable UniquePrefix {
    description = "A prefix that identifies this aks cluster"
    type = string
}
variable SharedPrefix {
    description = "A user defined prefix of this cluster"
    type = string
}
variable ResourceGroupName {
    description = "The resource group to deploy the cluster"
    type = string
}
variable Location {
    description = "The location to deploy the cluster"
    type = string
    default = "GermanyWestCentral"
}
variable NodeSize {
    description = "The VM size of the worker nodes"
    type = string
    default = "Standard_B2s"
}
variable NodeCount {
    description = "The number of worker nodes"
    type = number
    default = 1
}
variable "NodeDiskSize" {
  description = "The size of the OS disk of the node in Gibibytes."
  type = number
}
variable HttpApplicationRouting {
    description = "Should the http application routing be enabled for demonstration purposes?"
    type = bool
    default = true
}
variable NetworkPlugin {
    description = "The network plugin that should be used."
    type = string
    default = "kubenet"
}
variable NetworkPolicy {
    description = "The network policy that should be used."
    type = string
    default = "calico"
}
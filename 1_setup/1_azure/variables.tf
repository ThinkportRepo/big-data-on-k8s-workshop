variable NumberOfClusters {
    description = "The desired number of clusters that should be deployed"
    type = number
}
variable SharedPrefix {
    description = "A prefix that is shared among all clusters"
    type = string
}
variable ResourceGroupName {
    description = "The resource group to deploy the clusters"
    type = string
    default = "tp"
}
variable Location {
    description = "The location to deploy the clusters"
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
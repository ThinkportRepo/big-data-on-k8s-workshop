#variable NumberOfClusters {
#    description = "The desired number of clusters that should be deployed"
#    type = number
#}
variable UniquePrefix {
    description = "A prefix that identifies this aks cluster"
    type = string
}

locals {
  UniquePrefix = var.UniquePrefix == "" ? terraform.workspace : var.UniquePrefix
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
variable "NodeDiskSize" {
  description = "The size of the OS disk of the node in Gibibytes."
  type = number
  default = 30
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
variable GitHubRepoToken {
    description = "The GitHub token of the repository that should be cloned in the vscode deployment by Helm"
    type = string
}
#variable GitHubPackagesToken {
#    description = "The GitHub token used for accessing images on ghcr.io"
#    type = string
#}
variable GitHubUsername {
    description = "The Github username for the new fine-grained API-Token (GitHubRepoToken)"
    type = string
    sensitive   = true

}
#variable CloudFlareToken {
#    description = "API Token for CloudFlare (DNS zone based)"
#    type = string
#    sensitive   = true
#}

#variable CloudFlareDNSZoneID {
#    description = "CloudFlare ZoneID belonging to the API Token"
#    type = string
#    sensitive   = true
#}
#variable CloudFlareDNS {
#    description = "Name of your DNS Zone (CloudFlare)" 
#    type = string
#}
#variable CloudFlareEmail {
#    description = "EMail address of the account that created the API token"
#    type = string
#    sensitive   = true
#}
#variable "ACMEServer" {
#    description = "The server for ACME challenges"
#    default = "https://acme-staging-v02.api.letsencrypt.org/directory"
#    type = string
#}
#variable "ACMEAdminEmail" {
#    description = "The EMail for the ACME registration"
#    type = string
#    sensitive   = true
#}
#Dockerhub Credentials #FIXME
variable "DockerhubUser" {
    description = "The Dockerhub username"
    type = string
    sensitive   = true
}

variable "DockerhubPAT" {
    description = "Dockerhub Personal Access Token"
    type = string
    sensitive   = true
}
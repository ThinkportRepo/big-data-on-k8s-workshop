variable "ClusterName" {
  type = string
}

variable "ClusterDNS" {
    type = string
}

variable "kubeconfig" {
  type = string
}

#variable TlsCertificate {
#  type = string
#}

#variable TlsKey {
#  type = string
#}

variable GitHubRepoToken {
  type = string
}

#variable CloudFlareToken {
#    description = "API Token for CloudFlare (DNS zone based)"
#    type = string
#}

#variable CloudFlareDNSZoneID {
#    description = "CloudFlare ZoneID belonging to the API Token"
#    type = string
#}

variable GitHubUsername {
    description = "The Github username for the new fine-grained API-Token (GitHubRepoToken)"
    type = string
}
#variable GitHubPackagesToken {
#    description = "The GitHub token used for accessing images on ghcr.io"
#    type = string
#}

variable "DockerhubUser" {
    description = "The Dockerhub username"
    type = string  
}

variable "DockerhubPAT" {
    description = "Dockerhub Personal Access Token"
    type = string
}
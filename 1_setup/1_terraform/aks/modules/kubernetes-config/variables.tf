variable "ClusterName" {
  type = string
}

variable "UserName" {
  type = string
}

variable "ClusterDNS" {
    type = string
}

variable "kubeconfig" {
  type = string
}

variable TlsCertificate {
  type = string
}

variable TlsKey {
  type = string
}

variable GitHubRepoToken {
  type = string
}
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

variable "AZ_Client_ID" {
    type = string
}

variable "AZ_Client_Secret" {
    type = string
}

variable "AZ_Tenant_ID" {
    type = string
}

variable "AZ_Environment" {
  type = string
  default = ""
}

variable "AZ_Subscription_ID" {
  type = string
}

variable "AZ_RG_Name" {
  type = string
}
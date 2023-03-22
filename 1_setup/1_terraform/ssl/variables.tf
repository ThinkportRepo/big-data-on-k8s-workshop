
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
variable Domain {
    description = "Name of your DNS Zone" 
    type = string
}
variable SharedPrefix {
    description = "A prefix that is shared among all clusters"
    type = string
}
#variable CloudFlareEmail {
#    description = "EMail address of the account that created the API token"
#    type = string
#    sensitive   = true
#}
variable "ACMEServer" {
    description = "The server for ACME challenges"
    default = "https://acme-staging-v02.api.letsencrypt.org/directory"
    type = string
}
variable "ACMEAdminEmail" {
    description = "The EMail for the ACME registration"
    type = string
    sensitive   = true
}
variable "ClusterFile" {
    description = "The file containing the cluster names for the subdomains"
    type = string 
}
variable "AZ_Subscription_ID" {
    type = string
    description = "Azure Subscription ID containing the rg with key vaults and dns zones"  
}
variable "AZ_SA_Key_Vault_Name" {
    type = string
    description = "Key vault containing the Service Account credentials"
}
variable "AZ_Cert_Key_Vault_Name" {
    type = string
    description = "Key vault which is the target for storing generated certificates"
}
variable "AZ_RG_Name" {
    type = string
    description = "Resource group in the Subscription that contains key vaults and dns zones"
}
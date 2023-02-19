
data "azurerm_key_vault" "creds" {
  name                = var.AZ_SA_Key_Vault_Name
  resource_group_name = var.AZ_RG_Name
}

data "azurerm_key_vault_secrets" "credentials" {
  key_vault_id = data.azurerm_key_vault.creds.id
}

data "azurerm_key_vault_secret" "cred_secret" {
  for_each     = toset(data.azurerm_key_vault_secrets.credentials.names)
  name         = each.key
  key_vault_id = data.azurerm_key_vault.creds.id
}

module "acme" {
  source = "./modules/acme-azure"
  Domain = var.Domain
  SubDomains = split("\n", chomp(file(var.ClusterFile)))
  AdminEmail = var.ACMEAdminEmail
  #APIKey = var.CloudFlareToken
  #APIEmail = var.CloudFlareEmail
  ACMEServer = var.ACMEServer
  AZ_Client_ID = data.azurerm_key_vault_secret.cred_secret["client-id"].value
  AZ_Client_Secret = data.azurerm_key_vault_secret.cred_secret["client-secret"].value
  AZ_Environment = ""
  AZ_Subscription_ID = var.AZ_Subscription_ID
  AZ_Tenant_ID = data.azurerm_key_vault_secret.cred_secret["tenant-id"].value
  AZ_RG_Name = var.AZ_RG_Name
}

data "azurerm_key_vault" "certs" {
  provider = azurerm.SA
  name                = var.AZ_Cert_Key_Vault_Name
  resource_group_name = var.AZ_RG_Name
}

resource "azurerm_key_vault_certificate" "acme_cert" {
  provider = azurerm.SA
  name         = replace(replace(var.Domain, ".", "-"), "*-", "")
  key_vault_id = data.azurerm_key_vault.certs.id

  certificate {
    contents = module.acme.certificate_p12
    password = ""
  }
}


#resource "local_file" "private_key" {
#    filename = "../aks/k8s-${var.CloudFlareDNS}.key"
#    content = module.acme.private_key
#} 
#resource "local_file" "certificate" {
#    filename = "../aks/k8s-${var.CloudFlareDNS}.pem"
#    content = module.acme.certificate
#} 
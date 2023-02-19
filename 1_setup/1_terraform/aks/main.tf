module "aks" {
  source                    = "./modules/aks"
  UniquePrefix = local.UniquePrefix
  SharedPrefix = var.SharedPrefix
  ResourceGroupName = var.ResourceGroupName
  Location = var.Location
  NodeSize = var.NodeSize
  NodeCount = var.NodeCount
  NodeDiskSize = var.NodeDiskSize
  HttpApplicationRouting = var.HttpApplicationRouting
  NetworkPlugin = var.NetworkPlugin
  NetworkPolicy = var.NetworkPolicy
}

resource "local_file" "kube_config" {
    filename = "./logs/${local.UniquePrefix}.config"
    content = module.aks.kube_config
} 

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

data "azurerm_key_vault" "certs" {
  provider = azurerm.SA
  name                = var.AZ_Cert_Key_Vault_Name
  resource_group_name = var.AZ_RG_Name
}

data "azurerm_key_vault_certificate_data" "acme_cert" {
  provider = azurerm.SA
  name         = replace(replace(var.Domain, ".", "-"), "*-", "")
  key_vault_id = data.azurerm_key_vault.certs.id
}

module "kubernetes-config" {
  depends_on   = [module.aks]
  source       = "./modules/kubernetes-config"
  ClusterName = module.aks.kubernetes_cluster_name
  UserName = local.UniquePrefix
  kubeconfig   = data.azurerm_kubernetes_cluster.this.kube_config_raw
  TlsCertificate = data.azurerm_key_vault_certificate_data.acme_cert.pem
  TlsKey = data.azurerm_key_vault_certificate_data.acme_cert.key
  ClusterDNS = "${local.UniquePrefix}.${var.SharedPrefix}.${var.Domain}"
  AZ_Client_ID = data.azurerm_key_vault_secret.cred_secret["client-id"].value
  AZ_Client_Secret = data.azurerm_key_vault_secret.cred_secret["client-secret"].value
  AZ_Environment = ""
  AZ_Subscription_ID = var.AZ_Subscription_ID
  AZ_Tenant_ID = data.azurerm_key_vault_secret.cred_secret["tenant-id"].value
  AZ_RG_Name = var.AZ_RG_Name
  GitHubUsername = var.GitHubUsername
  GitHubRepoToken = var.GitHubRepoToken
 #GitHubPackagesToken = var.GitHubPackagesToken
  DockerhubUser = var.DockerhubUser
  DockerhubPAT = var.DockerhubPAT
}

resource "local_file" "dns_zone" {
    filename = "./logs/${local.UniquePrefix}-dns.txt"
    content = module.aks.dns_zone
} 

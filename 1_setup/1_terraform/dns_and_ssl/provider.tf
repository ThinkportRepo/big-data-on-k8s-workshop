
terraform {
  backend "local" { }
  required_providers {
      acme = {
        source  = "vancluever/acme"
        version = "~> 2.0"
    }
      azurerm = {
        version = "~> 3.41"
      }
  }
}
provider "azurerm" {
  features {
  }
  skip_provider_registration = true
}

provider "azurerm" {
  features {
    
  }
  skip_provider_registration = true
  alias = "SA"
  subscription_id = var.AZ_Subscription_ID
  client_id = data.azurerm_key_vault_secret.cred_secret["client-id"].value
  client_secret = data.azurerm_key_vault_secret.cred_secret["client-secret"].value
  tenant_id = data.azurerm_key_vault_secret.cred_secret["tenant-id"].value
}
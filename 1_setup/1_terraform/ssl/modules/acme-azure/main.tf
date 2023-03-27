terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
  }
}

provider "acme" {
  server_url = var.ACMEServer
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = var.AdminEmail
}

resource "acme_certificate" "certificate" {
  account_key_pem           = acme_registration.reg.account_key_pem
  common_name               = "${var.SharedPrefix}.${var.Domain}"
  subject_alternative_names = concat(["${var.SharedPrefix}.${var.Domain}"],[for subdomain in var.SubDomains: ["*.${subdomain}.${var.SharedPrefix}.${var.Domain}","${subdomain}.${var.SharedPrefix}.${var.Domain}"]]...)

  dns_challenge {
    provider = "azure"
    config = {
      ARM_CLIENT_ID = var.AZ_Client_ID 
      ARM_CLIENT_SECRET = var.AZ_Client_Secret 
      AZURE_ENVIRONMENT = var.AZ_Environment 
      ARM_SUBSCRIPTION_ID = var.AZ_Subscription_ID
      ARM_TENANT_ID = var.AZ_Tenant_ID
      ARM_RESOURCE_GROUP = var.AZ_RG_Name
      AZURE_ZONE_NAME = var.Domain
    }
  }
}
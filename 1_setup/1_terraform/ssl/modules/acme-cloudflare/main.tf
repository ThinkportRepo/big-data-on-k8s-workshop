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
  common_name               = "k8s.${var.Domain}"
  subject_alternative_names = concat([for subdomain in var.SubDomains: ["*.${subdomain}.k8s.${var.Domain}","${subdomain}.k8s.${var.Domain}"]]...)

  dns_challenge {
    provider = "cloudflare"
    config = {
        CF_DNS_API_TOKEN=var.APIKey
        #CF_API_EMAIL = var.APIEmail
    }
  }
}
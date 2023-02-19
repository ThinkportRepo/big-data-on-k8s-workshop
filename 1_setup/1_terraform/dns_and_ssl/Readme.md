# ACME Certificates 
This terraform code takes the subdomains (cluster names) from a file and creates a single certificate using SANs for them. 
In this case Cloudflare is used as DNS provider. 

# Configuration
All values can be set in a tfvars file. 

## Overview

| Parameter           | Description                                                                                            |
|---------------------|--------------------------------------------------------------------------------------------------------|
| CloudFlareToken     | API Access Token from CloudFlare                                                                       |
| CloudFlareDNSZoneID | ZoneID of your DNS Zone                                                                                |
| CloudFlareDNS       | Name of your DNS Zone (literally the name)                                                             |
| CloudFlareEmail     | Your CloudFlare Login Email address                                                                    |
| ACMEServer          | The server of the ACME Service you want to use (see example tfvars for Let's Encrypt prod and staging) |
| ACMEAdminEmail      | Email address for getting messages from your ACME provider                                             |
| ClusterFile         | Path to the text file containing your cluster names (one name per line)                                |

# Certificate
The create certificate will be written to `../aks/k8s-${var.CloudFlareDNS}.pem` (certificate only) and `../aks/k8s-${var.CloudFlareDNS}.key` (private key).
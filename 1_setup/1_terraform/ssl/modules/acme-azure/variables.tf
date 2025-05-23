variable Domain {
    type = string 
}

variable "SubDomains" {
    type = list(string)
}

variable AdminEmail {
    type = string
}

variable ACMEServer {
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
variable SharedPrefix {
    description = "A prefix that is shared among all clusters"
    type = string
}
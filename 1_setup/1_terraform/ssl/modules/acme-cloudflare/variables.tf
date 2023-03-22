variable Domain {
    type = string 
}

variable "SubDomains" {
    type = list(string)
}

variable AdminEmail {
    type = string
}

variable APIKey {
    type = string  
}

variable APIEmail {
  type = string
}

variable ACMEServer {
    type = string  
}
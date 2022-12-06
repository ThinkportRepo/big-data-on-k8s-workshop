locals {
  namespaces = toset([ "default", "minio", "hive" ])
}
#Image Pull Secrets 
resource "kubernetes_secret" "dockerhub" {
  for_each = local.namespaces #Add more namespaces by extending the list
 #   depends_on = [ # and adding them to the dependencies here
 #   kubernetes_namespace.tools,
 #   kubernetes_namespace.ingress,
 # ]
  metadata {
    name = "dockerhub-cfg"
    namespace = each.value
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "https://index.docker.io/v1/" = {
          "username" = var.DockerhubUser
          "password" = var.DockerhubPAT
          "auth"     = base64encode("${var.DockerhubUser}:${var.DockerhubPAT}")
        }
      }
    })
  }
}

#This secret can be used to access GitHubs Container Registry
# resource "kubernetes_secret" "github" {
#   for_each = toset([ "default", "tools", "ingress" ])
#     depends_on = [
#     kubernetes_namespace.tools,
#     kubernetes_namespace.ingress,
#   ]
#   metadata {
#     name = "ghcr-cfg"
#     namespace = each.value
#   }

#   type = "kubernetes.io/dockerconfigjson"

#   data = {
#     ".dockerconfigjson" = jsonencode({
#       auths = {
#         "https://ghcr.io/" = {
#           "username" = "notneeded"
#           "password" = var.GitHubPackagesToken
#           "auth"     = base64encode("notneeded:${var.GitHubPackagesToken}")
#         }
#       }
#     })
#   }
# }


#Namespaces #Examples for defining namespaces
resource "kubernetes_namespace" "ns" {
  for_each = setsubtract(local.namespaces, ["default"])
  metadata {
    name = each.value
  }
}
# resource "kubernetes_namespace" "ingress" {
#       metadata {
#         name = "ingress"
#       }
# }

# resource "kubernetes_namespace" "tools" {
#       metadata {
#         name = "tools"
#       }
# }

#SA configuration
resource "kubernetes_default_service_account" "default" {
  for_each = local.namespaces #Use the same namespaces as for the container registry secret above
  metadata {
    namespace = each.value
  }
  image_pull_secret {
    name = kubernetes_secret.dockerhub[each.key].metadata.0.name
  }
 #GitHub Container Registry
 # image_pull_secret {
 #   name = kubernetes_secret.github[each.key].metadata.0.name
 # }
}

# #TLS # Can be used if valid certificates are available
# resource "kubernetes_secret" "tls_cert" {
#   depends_on = [
#       kubernetes_namespace.ingress
#   ]
#     metadata {
#       name = "tls-cert"
#       namespace = "ingress"
#     }
#     data = {
#         "tls.crt" = var.TlsCertificate
#         "tls.key" = var.TlsKey
#     }
#     type = "kubernetes.io/tls"
# }

#Example for a pvc
# #Persistent Volume Claim
# resource "kubernetes_persistent_volume_claim" "workshop" {
#   metadata {
#     name = "workshop"
#     namespace = kubernetes_namespace.tools.metadata.0.name
#   }
#   spec {
#     access_modes = ["ReadWriteMany"]
#     resources {
#       requests = {
#         storage = "5Gi"
#       }
#     }
#     storage_class_name = "azurefile"
#   }
# }


#Helm stuff
#Deploys Ingress Controller (non-azure)
# resource "helm_release" "nginx_ingress" {
#   depends_on = [
#       kubernetes_namespace.ingress,
#       kubernetes_secret.tls_cert
#   ]
#   name       = "nginx-ingress-controller"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "nginx-ingress-controller"
#   namespace = "ingress"

#   set {
#     name  = "service.type"
#     value = "LoadBalancer"
#   }
#   set {
#     name = "ingressClassResource.default"
#     value = true
#   }
#   set {
#     name = "publishService.enabled"
#     value = true
#   }
#   set {
#     name = "extraArgs.default-ssl-certificate"
#     value = "${kubernetes_secret.tls_cert.metadata.0.namespace}/${kubernetes_secret.tls_cert.metadata.0.name}"
#   }
# }

#External DNS Controller (non-azure Domains)
# resource "helm_release" "external_dns" {
#   depends_on = [
#       kubernetes_namespace.ingress
#   ]
#   name       = "external-dns"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "external-dns"
#   namespace = "ingress"
  
#   set {
#     name  = "sources[0]"
#     value = "ingress"
#   }
#   set {
#     name  = "provider"
#     value = "cloudflare"
#   }
#   set {
#     name  = "cloudflare.apiToken"
#     value = var.CloudFlareToken
#   }
#   set {
#     name = "txtOwnerId"
#     value = var.ClusterDNS
#   }
#   set {
#     name = "zoneIdFilters[0]"
#     value = var.CloudFlareDNSZoneID
#   }
#   set {
#     name = "cloudflare.proxied"
#     value = false
#   }
#   set {
#     name = "policy"
#     value = "sync"
#   }
# }

resource "helm_release" "minio" {
  name = "minio"
  repository = "https://charts.min.io/"
  chart = "minio"
  namespace = kubernetes_namespace.ns["minio"].metadata.0.name
  values = [
    "${file("../2_minio/values.yaml")}"
  ]
  set {
    name = "consoleIngress.hosts[0]"
    value = "minio.${var.ClusterDNS}"
  }
}

resource "helm_release" "hive" {
  depends_on = [
    helm_release.minio
  ]
  namespace = kubernetes_namespace.ns["hive"].metadata.0.name
  chart = "../3_hive/"
  name = "hive-metastore"
    values = [
    "${file("../3_hive/values.yaml")}"
  ]

}

# resource "helm_release" "vscode" {
#     depends_on = [
#       kubernetes_namespace.tools,
#       kubernetes_persistent_volume_claim.workshop
#     ]
#     name = "vscode"
#     chart = "../7_frontends/3_vscode/chart"
#     namespace = "tools"

#     set {
#         name = "host" 
#         value = "vscode.${var.ClusterDNS}"
#     }
#     set {
#         name = "ghtoken"
#         value = var.GitHubRepoToken
#     }
#     set {
#         name = "ghuser"
#         value = var.GitHubUsername
#     }
# #    set {
# #      name = "serviceAccount.imagePullSecrets[0]"
# #      value = "ghcr-cfg"
# #    }
#     set {
#       name = "serviceAccount.imagePullSecrets[0]"
#       value = "dockerhub-cfg"
#     }
# }

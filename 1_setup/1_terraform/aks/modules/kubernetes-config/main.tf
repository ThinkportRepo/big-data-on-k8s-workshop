############################
####Namespaces & Secrets####
############################
locals {
  namespaces = toset([ "default", "minio", "hive", "kafka", "spark", "trino", "frontend", "ingress", "nosql", "monitoring", "sheduling" ])
}
resource "kubernetes_namespace" "ns" {
  for_each = setsubtract(local.namespaces, ["default"])
  metadata {
    name = each.value
  }
}
#Image Pull Secrets 
resource "kubernetes_secret" "dockerhub" {
  for_each = local.namespaces 
  metadata {
    name = "dockerhub-cfg"
    namespace = each.key != "default" ? kubernetes_namespace.ns[each.value].metadata.0.name : "default"
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

resource "kubernetes_secret" "kubeconfig" {
  metadata{
    name = "kubeconfig"
    namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  }  
  
  data = {
    "kubeconfig" = var.kubeconfig
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
 resource "kubernetes_secret" "tls_cert" {
   depends_on = [
       kubernetes_namespace.ns["ingress"]
   ]
     metadata {
       name = "tls-cert"
       namespace = "ingress"
     }
     data = {
         "tls.crt" = var.TlsCertificate
         "tls.key" = var.TlsKey
     }
     type = "kubernetes.io/tls"
 }

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


############################
#######Helm Charts #########
############################

############################
#########TLS & DNS##########
############################
resource "kubernetes_config_map" "nginx" {
  metadata {
    name = "nginx-ingress-controller"
    namespace = kubernetes_namespace.ns["ingress"].metadata.0.name
  }
  data = {
    force-ssl-redirect: "true"
  }
}
#Deploys Ingress Controller (non-azure)
 resource "helm_release" "nginx_ingress" {
   depends_on = [
       kubernetes_namespace.ns["ingress"],
       kubernetes_secret.tls_cert
   ]
   name       = "nginx-ingress-controller"
   repository = "https://charts.bitnami.com/bitnami"
   chart      = "nginx-ingress-controller"
   namespace = "ingress"
   set {
     name  = "service.type"
     value = "LoadBalancer"
   }
   set {
     name = "ingressClassResource.default"
     value = true
   }
   set {
     name = "publishService.enabled"
     value = true
   }
   set {
     name = "extraArgs.default-ssl-certificate"
     value = "${kubernetes_secret.tls_cert.metadata.0.namespace}/${kubernetes_secret.tls_cert.metadata.0.name}"
   }
   set {
     name = "configMapNamespace"
     value = kubernetes_namespace.ns["ingress"].metadata.0.name
   }
 }

#External DNS Controller (non-azure Domains)
 resource "helm_release" "external_dns" {
   depends_on = [
       kubernetes_namespace.ns["ingress"]
   ]
   name       = "external-dns"
   repository = "https://charts.bitnami.com/bitnami"
   chart      = "external-dns"
   namespace = "ingress"
 
   set {
     name  = "sources[0]"
     value = "ingress"
   }
   set {
     name  = "provider"
     value = "azure"
   }
   set {
     name  = "azure.cloud"
     value = var.AZ_Environment
   }
   set {
     name = "azure.resourceGroup"
     value = var.AZ_RG_Name
   }
   set {
     name = "azure.tenantId"
     value = var.AZ_Tenant_ID
   }
    set {
     name = "azure.subscriptionId"
     value = var.AZ_Subscription_ID
   }
   set {
     name = "azure.aadClientId"
     value = var.AZ_Client_ID
   }
   set {
     name = "azure.aadClientSecret"
     value = var.AZ_Client_Secret
   }
  set {
    name = "policy"
    value = "sync"
  }
    set {
    name = "txtOwnerId"
    value = var.ClusterDNS
  }
 }
 
##################
#### Minio S3  ###
##################

resource "helm_release" "minio" {
  depends_on = [
    kubernetes_default_service_account.default["minio"],
    helm_release.nginx_ingress
  ]
  name = "minio"
  repository = "https://charts.min.io/"
  chart = "minio"
  namespace = kubernetes_namespace.ns["minio"].metadata.0.name
  values = [
    "${file("../../2_minio/values.yaml")}"
  ]
  set {
    name = "consoleIngress.hosts[0]"
    value = "minio.${var.ClusterDNS}"
  }
  timeout = 1600
}

##################
#### Hive      ###
##################
resource "helm_release" "hive" {
  depends_on = [
    helm_release.minio
  ]
  namespace = kubernetes_namespace.ns["hive"].metadata.0.name
  chart = "../../3_hive/"
  name = "hive-metastore"
    values = [
    "${file("../../3_hive/values.yaml")}"
  ]
  set {
    name = "schemainit"
    value = true
  }
    timeout = 600
}


##################
#### Kafka  ###
##################
resource "helm_release" "kafka-operator" {
  #depends_on = [
  #  helm_release.hive
  #]
  name = "kafka-operator"
  namespace = kubernetes_namespace.ns["kafka"].metadata.0.name
  chart = "confluent-for-kubernetes"
  repository = "https://packages.confluent.io/helm"
  #values = [
  #  "${file("../../4_kafka/values.yaml")}"
  #]
  timeout = 900
}

resource "helm_release" "kafka-resources" {
  depends_on = [
    helm_release.kafka-operator
  ]
  name = "kafka-resources"
  namespace = kubernetes_namespace.ns["kafka"].metadata.0.name
  chart = "../../4_kafka/chart/"
  values = [
    "${file("../../4_kafka/chart/values.yaml")}"
  ]
  set {
    name = "ingress.host"
    value = "${var.ClusterDNS}"
  }
  timeout = 600
}

# resource "kubernetes_service_account" "spark" {
#   metadata {
#     name = "spark"
#     namespace = kubernetes_namespace.ns["spark"].metadata.0.name
#   }
#   image_pull_secret {
#     name = kubernetes_secret.dockerhub["spark"].metadata.0.name
#   }
# }
##################
#### Spark     ###
##################
resource "helm_release" "spark" {
  depends_on = [
    helm_release.minio,
  ]
  name = "spark"
  namespace = kubernetes_namespace.ns["spark"].metadata.0.name
  chart = "spark-operator"
  repository = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
  set {
    name = "webhook.enable"
    value = true
  }
  set {
    name = "sparkJobNamespace"
    value = "spark"
  }
  set {
    name = "image.tag"
    value = "v1beta2-1.3.3-3.1.1"
  }
  set {
    name = "serviceAccounts.spark.name"
    value = "spark"
  }
  set {
    name = "ingress-url-format"
    value = "spark.${var.ClusterDNS}"
  }
}

##################
#### Trino     ###
##################
resource "helm_release" "trino" {
  depends_on = [
    helm_release.minio,
    helm_release.hive
  ]
  name = "trino"
  namespace = kubernetes_namespace.ns["trino"].metadata.0.name
  #chart = "trino"
  #repository = "https://trinodb.github.io/charts/"
  chart = "../../6_trino/"
  values = [
    "${file("../../6_trino/values.yaml")}"
  ]
  set {
    name = "host"
    value = "trino.${var.ClusterDNS}"
  }
  timeout = 600
}

###################
#### Cassandra  ###
###################
resource "helm_release" "cassandra" {
  depends_on = [
    helm_release.nginx_ingress
  ]
  name = "cassandra"
  repository = "https://charts.bitnami.com/bitnami"
  chart = "cassandra"
  namespace = kubernetes_namespace.ns["nosql"].metadata.0.name
  values = [
    "${file("../../9_cassandra/values.yaml")}"
  ]
  timeout = 600
}

##################
####Frontends####
##################

#StorageClass Spark History Server
resource "kubernetes_storage_class" "sc-spark-history-server" {
  metadata {
    name = "sc-spark-history-server"
  }
  storage_provisioner = "file.csi.azure.com"
  reclaim_policy      = "Retain"
  parameters = {
    skuName = "Standard_LRS"
  }
  mount_options = ["file_mode=0770", "dir_mode=0770", "mfsymlinks", "uid=185", "gid=185", "actimeo=30", "cache=strict"]
}

#Persistent Volume Claim
resource "kubernetes_persistent_volume_claim" "workshop" {
  metadata {
    name = "workshop"
    namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
    storage_class_name = "azurefile"
  }
}


resource "kubernetes_persistent_volume_claim" "spark" {
  metadata {
    name = "spark-history-server"
    namespace = kubernetes_namespace.ns["spark"].metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = kubernetes_storage_class.sc-spark-history-server.metadata.0.name
  }
}

resource "kubernetes_secret" "github" {
  metadata{
    name = "github"
    namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  }
  data = {
    git_token = var.GitHubRepoToken
    git_user = var.GitHubUsername
  }
}
resource "kubernetes_service_account" "kubectl" {
  metadata {
    name = "kubectl"
    namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  }
  image_pull_secret {
    name = kubernetes_secret.dockerhub["frontend"].metadata.0.name
  }
}

resource "kubernetes_cluster_role_binding" "kubectl" {
  metadata {
    name = "kubectl"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }
  subject {
    kind = "ServiceAccount"
    name = "kubectl"
    namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  }
}

resource "kubernetes_config_map" "bashrc" {
  metadata {
    name = "bashrc"
    namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  }
  data = {
    ".bashrc" = <<EOT
    source <(kubectl completion bash)
    alias k=kubectl
    complete -o default -F __start_kubectl k
    alias s3=s3cmd
    alias kn=kubens
    export KUBECONFIG=/home/coder/.kube/kubeconfig
    export KUBECACHEDIR=/tmp/kubecache
    export PS1="\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
    source /usr/share/bash-completion/bash_completion
    EOT
  }
}
resource "kubernetes_config_map" "s3cmd" {
  metadata {
    name = "s3cmd"
    namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  }
  data = {
    ".s3cfg" = "${file("../../7_frontends/0_initialisation/.s3cfg")}"
  }
  
}

resource "kubernetes_config_map" "vscode-settings" {
  metadata {
    name = "vscode"
    namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  }
  data = {
    "settings.json" = <<EOT
    {
    "files.exclude": {
        "**/.*": true
    },
    "terminal.integrated.copyOnSelection": true
    }
    EOT
  } 
}




# resource "kubernetes_pod" "admin" {
#   metadata {
#     name = "admin"
#     namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
#   }  
#   spec {
#     container {
#       name = "main"
#       image = "alpine:3.17"
#       command = ["sh", "-c", "apk add --no-cache curl; sleep 3000"]
#     }
#   }
# }
resource "kubernetes_job" "gitcloner" {
  depends_on = [
    kubernetes_secret.github,
  ]
  metadata {
      name = "gitcloner"
      namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
    }
  spec {
    template {
      metadata {
        
      }
      spec {
        service_account_name = kubernetes_service_account.kubectl.metadata.0.name
        restart_policy = "Never"
        container {
            name = "git"
            image = "alpine:3.17" 
            command = ["sh", "-c", 
              join("\n", ["apk add --no-cache git;",
              "echo \"### Environment Variables\";",
              "echo $GITHUB_USER;",
              "echo $GITHUB_TOKEN;",
              "echo $GITHUB_REPOSITORY;",
              "rm -rf /workshop/git;",
              "rm -rf /workshop/exercises;",
              "rm -rf /workshop/solutions;",
              "git clone https://oauth2:$${GITHUB_TOKEN}@github.com/$${GITHUB_REPOSITORY} /workshop/git;",
              #"mkdir /workshop/exercises;",
              #"mkdir /workshop/solutions;",
              "ln -s /workshop/git/2_lab/exercises /workshop;",
              "ln -s /workshop/git/2_lab/solutions /workshop;"
              ])
            ]
              env {
                name = "GITHUB_REPOSITORY"
                value = "ThinkportRepo/big-data-on-k8s-workshop.git"
                #value = "ThinkportRepo/k8s-lab.git"
              }
              env {
                name = "GITHUB_TOKEN"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.github.metadata.0.name
                    key = "git_token"
                  } 
                }
              }
              env {
                name = "GITHUB_USER"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.github.metadata.0.name
                    key = "git_user"
                  } 
                }
              }
              volume_mount {
                mount_path = "/workshop"
                name = "workshop"
              }
        }
        volume {
          name = "workshop"
          persistent_volume_claim {
            claim_name = "workshop"
          } 
        }
      }
    }
  }
  wait_for_completion = true
  timeouts {
    create = "4m"
    update = "2m"
  }
}
resource "kubernetes_job" "init" {
  depends_on = [
    kubernetes_secret.github,
    kubernetes_job.gitcloner,
    kubernetes_secret.kubeconfig,
    kubernetes_config_map.bashrc,
    kubernetes_service_account.kubectl,
    helm_release.minio
    ]
  metadata {
      name = "init"
      namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
    }
  spec {
    template {
      metadata {
        
      }
      spec {
        service_account_name = kubernetes_service_account.kubectl.metadata.0.name
        restart_policy = "Never"
        container {
            name = "vscode"
            image = "thinkportgmbh/workshops:vscode" 
            command = ["sh", "-c", 
              join("\n", ["echo \"start init ...\"",
                "echo \"################## Init Summary ############\";",
                "echo Github User: $GITHUB_USER;",
                "echo Github User: $GITHUB_REPOSITORY;",
                "echo ls /workshop/;",
                "ls /workshop/;",
                "echo ls /workshop/exercises/;",
                "ls /workshop/exercises/;",
                "echo ls /workshop/solutions;",
                "ls /workshop/git/2_lab/data/;",
                "echo kubectl get po;",
                "kubectl get po;",
                "s3cmd mb s3://data;",
                "s3cmd ls;",
                "s3cmd put /workshop/git/2_lab/data/ s3://data/ -r;",
                "s3cmd ls s3://data;",
                "echo \"############################################\";"]
                )
            ]
              env {
                name = "GITHUB_REPOSITORY"
                value = "ThinkportRepo/big-data-on-k8s-workshop.git"
                #value = "ThinkportRepo/k8s-lab.git"
              }
              env {
                name = "GITHUB_TOKEN"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.github.metadata.0.name
                    key = "git_token"
                  } 
                }
              }
              env {
                name = "GITHUB_USER"
                value_from {
                  secret_key_ref {
                    name = kubernetes_secret.github.metadata.0.name
                    key = "git_user"
                  } 
                }
              }
              volume_mount {
                mount_path = "/workshop"
                name = "workshop"
              }
              volume_mount {
                mount_path = "/config/"
                name = "kubeconfig"
              }
              volume_mount {
                mount_path = "/home/coder/.s3cfg"
                name = "s3cmd"
                sub_path = ".s3cfg"
              }
        }
        volume {
          name = "workshop"
          persistent_volume_claim {
            claim_name = "workshop"
          } 
        }
        volume {
          name = "s3cmd"
          config_map {
            name = "s3cmd"
          } 
        }
        volume {
          name = "kubeconfig"
          secret {
            secret_name = kubernetes_secret.kubeconfig.metadata.0.name
            optional = false
          }
        }
      }
    }
  }
  wait_for_completion = true
  timeouts {
    create = "4m"
    update = "2m"
  }
}

resource "helm_release" "dashboard" {
  depends_on = [
    helm_release.nginx_ingress
  ]
  namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  chart = "../../7_frontends/1_dashboard/chart"
  name = "dashboard"
    values = [
    "${file("../../7_frontends/1_dashboard/chart/values.yaml")}"
  ]
  set {
    name = "host"
    value = "dashboard.${var.ClusterDNS}"
  }
  set {
    name = "k8shost"
    value = var.ClusterDNS
  }
  set {
    name = "lab_user"
    value = var.UserName
  }
  set {
    name = "hosts[0]"
    value = "kube.${var.ClusterDNS}"
  }
  timeout = 600
}

resource "helm_release" "terminal" {
  depends_on = [
    kubernetes_job.init,
    kubernetes_config_map.bashrc,
    kubernetes_service_account.kubectl
  ]
  namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  chart = "../../7_frontends/2_terminal/chart"
  name = "terminal"
    values = [
    "${file("../../7_frontends/2_terminal/chart/values.yaml")}"
  ]
  set {
    name = "host"
    value = "terminal.${var.ClusterDNS}"
  }
  timeout = 600
}

resource "helm_release" "vscode" {
  depends_on = [
    kubernetes_job.init,
    kubernetes_config_map.bashrc,
    kubernetes_service_account.kubectl,
    kubernetes_secret.kubeconfig
    ]
  namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  chart = "../../7_frontends/3_vscode/chart"
  name = "vscode"
    values = [
    "${file("../../7_frontends/3_vscode/chart/values.yaml")}"
  ]
  set {
    name = "host"
    value = "vscode.${var.ClusterDNS}"
  }
  timeout = 600
}

resource "helm_release" "jupyter" {
  depends_on = [
    kubernetes_job.init,
    #helm_release.vscode
  ]
  namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  chart = "../../7_frontends/4_jupyter/chart"
  name = "jupyter"
    values = [
    "${file("../../7_frontends/4_jupyter/chart/values.yaml")}"
  ]
  set {
    name = "host"
    value = "jupyter.${var.ClusterDNS}"
  }
  set {
    name = "jupyter.persistence.enabled"
    value = false
  }
  timeout = 600
}

resource "helm_release" "sqlpad" {
  depends_on = [
    kubernetes_job.init,
    helm_release.trino
    #helm_release.vscode
  ]
  namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  chart = "../../7_frontends/5_sqlpad/chart"
  name = "sqlpad"
    values = [
    "${file("../../7_frontends/5_sqlpad/chart/values.yaml")}"
  ]
  set {
    name = "host"
    value = "sqlpad.${var.ClusterDNS}"
  }
  timeout = 600
}

resource "helm_release" "metabase" {
  depends_on = [
    kubernetes_job.init,
    helm_release.trino
    #helm_release.vscode
  ]
  namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  chart = "../../7_frontends/6_metabase"
  name = "metabase"
    values = [
    "${file("../../7_frontends/6_metabase/values.yaml")}"
  ]
  set {
    name = "ingress.host"
    value = "metabase.${var.ClusterDNS}"
  }
  timeout = 600
}

resource "helm_release" "history" {
  depends_on = [
    kubernetes_job.init,
    helm_release.spark,
    kubernetes_persistent_volume_claim.spark
  ]
  namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  chart = "../../7_frontends/7_history_server/chart"
  name = "history"
    values = [
    "${file("../../7_frontends/7_history_server/chart/values.yaml")}"
  ]
  set {
    name = "ingress.host"
    value = "spark.${var.ClusterDNS}"
  }
  timeout = 600
}

resource "helm_release" "headlamp" {
  depends_on = [
    kubernetes_job.init
  ]
  namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
  chart = "../../7_frontends/9_headlamp"
  name = "headlamp"
    values = [
    "${file("../../7_frontends/9_headlamp/values.yaml")}"
  ]
  set {
    name = "host"
    value = "headlamp.${var.ClusterDNS}"
  }
  timeout = 600
}


#resource "helm_release" "k8sdashboard" {
#  name = "kubernetes-dashboard"
#  repository = "https://kubernetes.github.io/dashboard/"
#  chart = "kubernetes-dashboard"
#  namespace = kubernetes_namespace.ns["frontend"].metadata.0.name
#  values = [
#    "${file("../../7_frontends/8_kube-ui/values.yaml")}"
#  ]
#  set {
#    name = "hosts[0]"
#    value = "kube.${var.ClusterDNS}"
#  }
#  timeout = 600
#}

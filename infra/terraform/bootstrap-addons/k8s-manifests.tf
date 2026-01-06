# Cria namespace datadog
resource "kubernetes_namespace" "datadog" {
  metadata {
    name = "datadog"
  }

  depends_on = [
    data.terraform_remote_state.bootstrap_core
  ]
}

# SecretStore namespaced - usa o ServiceAccount criado pelo External Secrets Operator
resource "kubernetes_manifest" "datadog_secretstore" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"

    metadata = {
      name      = "aws-ssm"
      namespace = kubernetes_namespace.datadog.metadata[0].name
    }

    spec = {
      provider = {
        aws = {
          service = "ParameterStore"
          region  = var.region
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = "external-secrets-sa"
                namespace = "external-secrets"
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.datadog,
    data.terraform_remote_state.bootstrap_core
  ]
}

# ExternalSecret que vai buscar secrets do SecretStore
resource "kubernetes_manifest" "datadog_external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"

    metadata = {
      name      = "datadog-api-key"
      namespace = kubernetes_namespace.datadog.metadata[0].name
    }

    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = kubernetes_manifest.datadog_secretstore.manifest.metadata.name
        kind = "SecretStore"
      }
      target = {
        name           = "datadog-secret"
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "api-key"
          remoteRef = {
            key = "/datadog/api-key"
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.datadog_secretstore,
    data.terraform_remote_state.bootstrap_core
  ]
}


resource "kubernetes_manifest" "limit_range" {
  manifest = {
    apiVersion = "v1"
    kind       = "LimitRange"
    metadata = {
      name      = "default-limits"
      namespace = "default"
    }
    spec = {
      limits = [
        {
          default = {
            cpu    = "500m"
            memory = "512Mi"
          }
          defaultRequest = {
            cpu    = "200m"
            memory = "256Mi"
          }
          type = "Container"
        }
      ]
    }
  }

  depends_on = [
    data.terraform_remote_state.cluster
  ]
}

resource "kubernetes_manifest" "resource_quota" {
  manifest = {
    apiVersion = "v1"
    kind       = "ResourceQuota"
    metadata = {
      name      = "default-quota"
      namespace = "default"
    }
    spec = {
      hard = {
        "requests.cpu"    = "2"
        "requests.memory" = "2Gi"
        "limits.cpu"      = "4"
        "limits.memory"   = "4Gi"
      }
    }
  }

  depends_on = [
    data.terraform_remote_state.cluster
  ]
}


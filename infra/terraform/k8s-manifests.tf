# External Secrets - SecretStore
resource "kubernetes_manifest" "external_secrets_secretstore" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"
    metadata = {
      name      = "aws-ssm"
      namespace = "datadog"
    }
    spec = {
      provider = {
        aws = {
          service = "ParameterStore"
          region  = var.aws_region
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
    helm_release.external_secrets
  ]
}

# External Secrets - ExternalSecret para Datadog
resource "kubernetes_manifest" "external_secret_datadog" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "datadog-api-key"
      namespace = "datadog"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-ssm"
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
    kubernetes_manifest.external_secrets_secretstore
  ]
}

# LimitRange para namespace default
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
    module.eks
  ]
}

# ResourceQuota para namespace default
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
    module.eks
  ]
}


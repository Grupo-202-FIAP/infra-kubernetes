# External Secrets - SecretStore (via Helm raw chart)
resource "helm_release" "external_secrets_secretstore" {
  name       = "external-secrets-secretstore"
  repository = "https://charts.helm.sh/incubator"
  chart      = "raw"
  namespace  = "external-secrets"

  values = [yamlencode({
    resources = [
      {
        apiVersion = "external-secrets.io/v1beta1"
        kind       = "SecretStore"
        metadata = {
          name      = "aws-ssm"
          namespace = "external-secrets"
        }
        spec = {
          provider = {
            aws = {
              service = "SSM"
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
    ]
  })]

  depends_on = [
    helm_release.external_secrets
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
    data.terraform_remote_state.cluster
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
    data.terraform_remote_state.cluster
  ]
}



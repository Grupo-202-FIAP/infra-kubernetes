# Helm Releases - Addons

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.6.0"
  namespace        = "argocd"
  create_namespace = true

  depends_on = [
    data.terraform_remote_state.cluster
  ]
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true

  values = [yamlencode({
    installCRDs = true

    serviceAccount = {
      create = true
      name   = "external-secrets-sa"
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
      }
    }
  })]

  depends_on = [
    data.terraform_remote_state.cluster,
    aws_iam_role.external_secrets
  ]
}


resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  values = [yamlencode({
    clusterName = data.terraform_remote_state.cluster.outputs.cluster_name
    serviceAccount = {
      create = true
      name   = "aws-load-balancer-controller"
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller.arn
      }
    }
  })]

  depends_on = [
    data.terraform_remote_state.cluster,
    aws_iam_role.aws_lb_controller
  ]
}

resource "helm_release" "ebs_csi" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"

  values = [yamlencode({
    controller = {
      serviceAccount = {
        create = true
        name   = "ebs-csi-controller-sa"
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi.arn
        }
      }
    }
  })]

  depends_on = [
    data.terraform_remote_state.cluster,
    aws_iam_role.ebs_csi
  ]
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  depends_on = [
    data.terraform_remote_state.cluster
  ]
}

resource "helm_release" "datadog" {
  name             = "datadog"
  repository       = "https://helm.datadoghq.com"
  chart            = "datadog"
  namespace        = "datadog"
  create_namespace = true

  values = [yamlencode({
    datadog = {
      apiKeyExistingSecret = "datadog-secret"
      site                 = "datadoghq.com"
      clusterName          = data.terraform_remote_state.cluster.outputs.cluster_name
      apm                  = { enabled = true }
      logs                 = { enabled = true }
    }

    extraObjects = [
      {
        apiVersion = "external-secrets.io/v1beta1"
        kind       = "ExternalSecret"
        metadata = {
          name      = "datadog-secret"
          namespace = "datadog"
        }
        spec = {
          refreshInterval = "1h"
          secretStoreRef = {
            name = "aws-ssm"
            kind = "SecretStore"
          }
          target = {
            name = "datadog-secret"
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
    ]
  })]

  depends_on = [
    helm_release.external_secrets,
    helm_release.external_secrets_secretstore
  ]
}




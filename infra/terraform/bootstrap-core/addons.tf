# Helm Releases - Addons que criam CRDs

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
  name       = "external-secrets"
  namespace  = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.20"

  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  values = [yamlencode({
    serviceAccount = {
      create = true
      name   = "external-secrets-sa"
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets.arn
      }
    }
  })]

  wait    = true
  timeout = 600

  depends_on = [
    data.terraform_remote_state.cluster,
    aws_iam_role.external_secrets
  ]
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.7.2"

  values = [yamlencode({
    clusterName = data.terraform_remote_state.cluster.outputs.cluster_name
    region      = "us-east-1"
    vpcId       = data.terraform_remote_state.infra_core.outputs.vpc_id

    serviceAccount = {
      create = true
      name   = "aws-load-balancer-controller"
      annotations = {
        "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller.arn
      }
    }
  })]

  depends_on = [
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

  values = [yamlencode({
    args = [
      "--kubelet-insecure-tls"
    ]
  })]

  depends_on = [
    data.terraform_remote_state.cluster
  ]
}


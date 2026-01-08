# ==========================================
# Helm Releases - Addons que criam CRDs
# ==========================================

# ----------------------
# ArgoCD
# ----------------------
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.6.0"
  namespace        = "argocd"
  create_namespace = true

  wait    = true
  timeout = 600

  depends_on = [
    data.terraform_remote_state.cluster
  ]
}

# ----------------------
# AWS Load Balancer Controller
# ----------------------
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

  wait    = true
  timeout = 600

  depends_on = [
    aws_iam_role.aws_lb_controller
  ]
}

# ----------------------
# External Secrets
# ----------------------
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
    aws_iam_role.external_secrets,
    helm_release.aws_lb_controller  # garante que o webhook do LB controller esteja pronto
  ]
}

# ----------------------
# AWS EBS CSI Driver
# ----------------------
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

  wait    = true
  timeout = 600

  depends_on = [
    data.terraform_remote_state.cluster,
    aws_iam_role.ebs_csi
  ]
}

# ----------------------
# Metrics Server
# ----------------------
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

  wait    = true
  timeout = 300

  depends_on = [
    data.terraform_remote_state.cluster
  ]
}

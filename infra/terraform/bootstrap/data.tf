data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-nextime"
    key    = "infra-kubernetes/cluster.tfstate"
    region = "us-east-1"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.cluster.outputs.cluster_name
}

data "aws_caller_identity" "current" {}

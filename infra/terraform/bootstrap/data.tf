data "terraform_remote_state" "infra_core" {
  backend = "s3"
  config = {
    bucket = "nextime-food-state-bucket"
    key    = "infra-core/terraform.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "nextime-food-state-bucket"
    key    = "infra-kubernetes/terraform.tfstate"
    region = "us-east-1"
  }
}


data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.cluster.outputs.cluster_name
}

data "aws_caller_identity" "current" {}

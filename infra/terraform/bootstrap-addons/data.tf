data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "nextime-food-state-bucket"
    key    = "infra-kubernetes/cluster.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "bootstrap_core" {
  backend = "s3"
  config = {
    bucket = "nextime-food-state-bucket"
    key    = "infra-kubernetes/bootstrap-core.tfstate"
    region = "us-east-1"
  }
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.cluster.outputs.cluster_name
}


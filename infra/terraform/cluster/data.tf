data "aws_caller_identity" "current" {}


data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "nextime-food-state-bucket"
    key    = "infra-core/infra.tfstate"
    region = "us-east-1"
  }
}
terraform {
  backend "s3" {
    bucket  = "nextime-food-state-bucket"
    key     = "infra-kubernetes/bootstrap-core.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

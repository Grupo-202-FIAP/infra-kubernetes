terraform {
  backend "s3" {
    bucket  = "nextime-food-state-bucket"
    key     = "infra-kubernetes/bootstrap.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
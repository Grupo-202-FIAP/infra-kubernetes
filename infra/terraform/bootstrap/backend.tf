terraform {
  backend "s3" {
    bucket  = "terraform-state-bucket-nextime"
    key     = "infra-kubernetes/bootstrap.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
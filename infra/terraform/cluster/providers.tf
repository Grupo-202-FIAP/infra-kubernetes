terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.30.0"
    }
  }

  backend "s3" {
    bucket  = "nextime-food-state-bucket"
    key     = "infra-kubernetes/cluster.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

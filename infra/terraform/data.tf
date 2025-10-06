data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state-bucket-nextime"
    key    = "infra.tfstate"
    region = "us-east-1"
  }
}
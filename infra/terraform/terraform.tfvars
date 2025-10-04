aws_region          = "us-east-1"
environment         = "dev"
cluster_name        = "nexTime-cluster"
cluster_version     = "1.28"
node_role_arn       = "arn:aws:iam::975049999399:role/LabRole" # IAM role para os nodes
cluster_role_arn    = "arn:aws:iam::975049999399:role/LabRole" # IAM role para o cluster
node_min_size       = 2
node_max_size       = 5
node_desired_size   = 2
node_instance_types = ["t3.medium"]
tags                = {
  Environment = "dev"
  Project     = "nexTime"
}
endpoint_private_access = true
endpoint_public_access  = true
public_access_cidrs     = ["0.0.0.0/0"]

locals {
  subnet_ids = data.terraform_remote_state.network.outputs.public_subnet_ids
}

module "eks" {
  source      = "./modules/eks"
  environment = var.environment

  cluster_name     = var.cluster_name
  cluster_version  = var.cluster_version
  cluster_role_arn = aws_iam_role.eks_cluster.arn

  subnet_ids = local.subnet_ids

  ami_type = var.ami_type

  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs     = var.public_access_cidrs

  node_role_arn       = aws_iam_role.eks_node.arn
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_desired_size   = var.node_desired_size
  node_instance_types = var.node_instance_types

  tags = var.tags
}

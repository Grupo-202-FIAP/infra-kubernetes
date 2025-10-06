module "eks" {
  source = "./modules/eks"
  environment = var.environment

  # Cluster
  cluster_name      = var.cluster_name
  cluster_version   = var.cluster_version
  cluster_role_arn  = var.cluster_role_arn

  subnet_ids               = data.terraform_remote_state.network.outputs.public_subnet_ids

  endpoint_private_access       = var.endpoint_private_access
  endpoint_public_access        = var.endpoint_public_access
  public_access_cidrs           = var.public_access_cidrs

  # Node Group
  node_role_arn         = var.node_role_arn
  node_min_size         = var.node_min_size
  node_max_size         = var.node_max_size
  node_desired_size     = var.node_desired_size
  node_instance_types   = var.node_instance_types

  # Tags
  tags = var.tags
}

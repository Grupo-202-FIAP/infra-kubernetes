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

  cluster_security_group_id = aws_security_group.eks_cluster_sg.id
  node_security_group_id    = aws_security_group.eks_nodes_sg.id

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

resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "EKS Cluster Security Group"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description     = "Allow nodes to communicate with cluster API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.cluster_name}-cluster-sg"
    },
    var.tags
  )
}

resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.cluster_name}-nodes-sg"
  description = "EKS Worker Nodes Security Group"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    description = "Node to node communication"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.cluster_name}-nodes-sg"
    },
    var.tags
  )
}


resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = [var.cluster_security_group_id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  tags = merge(
    {
      Name        = var.cluster_name
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-default"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  ami_type = var.ami_type

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  instance_types = var.node_instance_types

  remote_access {
    ec2_ssh_key               = null
    source_security_group_ids = []
  }

  launch_template {
    id      = aws_launch_template.nodes.id
    version = "$Latest"
  }

  tags = merge(
    {
      Name        = "${var.cluster_name}-node"
      Environment = var.environment
    },
    var.tags
  )

  depends_on = [aws_eks_cluster.this]
}

resource "aws_launch_template" "nodes" {
  name_prefix   = "${var.cluster_name}-nodes-"
  instance_type = var.node_instance_types[0]

  network_interfaces {
    security_groups = [var.node_security_group_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = "${var.cluster_name}-node"
      },
      var.tags
    )
  }
}


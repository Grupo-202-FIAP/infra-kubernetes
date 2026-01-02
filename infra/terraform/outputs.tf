output "cluster_name" {
  value = var.cluster_name
}

output "cluster_role_arn" {
  description = "ARN da IAM role do cluster EKS"
  value       = aws_iam_role.eks_cluster.arn
}

output "node_role_arn" {
  description = "ARN da IAM role dos nodes EKS"
  value       = aws_iam_role.eks_node.arn
}
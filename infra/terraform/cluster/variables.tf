variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
}

variable "ami_type" {
  description = "AMI type for EKS nodes"
  type        = string
  default     = "AL2_x86_64"
}

variable "endpoint_private_access" {
  description = "Enable private access to EKS API"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public access to EKS API"
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDRs allowed to access EKS public endpoint"
  type        = list(string)
  default     = []
}

variable "node_min_size" {
  type = number
}

variable "node_max_size" {
  type = number
}

variable "node_desired_size" {
  type = number
}

variable "node_instance_types" {
  description = "EC2 instance types for node group"
  type        = list(string)
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

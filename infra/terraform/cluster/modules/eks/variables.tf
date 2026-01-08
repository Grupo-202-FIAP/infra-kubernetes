variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "cluster_role_arn" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ami_type" {
  type = string
}

variable "endpoint_private_access" {
  type = bool
}

variable "endpoint_public_access" {
  type = bool
}

variable "public_access_cidrs" {
  type = list(string)
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
  type = list(string)
}

variable "cluster_security_group_id" {
  description = "Security Group ID for EKS control plane"
  type        = string
}

variable "node_security_group_id" {
  description = "Security Group ID for EKS worker nodes"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

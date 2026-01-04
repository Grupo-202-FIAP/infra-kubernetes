variable "cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
}

variable "cluster_version" {
  description = "Versão do Kubernetes para o cluster."
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN da IAM role usada pelo cluster."
  type        = string
}

variable "node_role_arn" {
  description = "ARN da IAM role usada pelos nodes do EKS."
  type        = string
}

variable "subnet_ids" {
  description = "Lista de subnets onde o cluster e node groups serão provisionados."
  type        = list(string)
}

variable "node_min_size" {
  description = "Número mínimo de nós no node group."
  type        = number
}

variable "node_max_size" {
  description = "Número máximo de nós no node group."
  type        = number
}

variable "node_desired_size" {
  description = "Número desejado de nós no node group."
  type        = number
}

variable "node_instance_types" {
  description = "Tipos de instância para os nodes."
  type        = list(string)
}

variable "environment" {
  description = "Nome do ambiente para tagging."
  type        = string
}

variable "tags" {
  description = "Tags adicionais para recursos."
  type        = map(string)
}

variable "endpoint_private_access" {
  description = "Habilitar acesso privado ao endpoint do EKS."
  type        = bool
}

variable "endpoint_public_access" {
  description = "Habilitar acesso público ao endpoint do EKS."
  type        = bool
}

variable "public_access_cidrs" {
  description = "Lista de CIDRs que podem acessar o endpoint público do EKS."
  type        = list(string)
}

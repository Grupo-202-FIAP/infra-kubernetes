variable "cluster_name" {
  type        = string
  description = "Nome do cluster EKS"
}

variable "environment" {
  type        = string
  description = "Ambiente do cluster EKS"
}

variable "cluster_version" {
  type        = string
  description = "Versão do cluster EKS"
}

variable "cluster_role_arn" {
  type        = string
  description = "IAM Role ARN para o cluster"
}

variable "endpoint_private_access" {
  type        = bool
  description = "Habilita acesso privado ao endpoint do cluster"
}

variable "endpoint_public_access" {
  type        = bool
  description = "Habilita acesso público ao endpoint do cluster"
}

variable "public_access_cidrs" {
  type        = list(string)
  description = "CIDRs permitidos para acesso público ao endpoint"
}

variable "node_role_arn" {
  type        = string
  description = "IAM Role ARN para os nodes"
}

variable "node_min_size" {
  type        = number
  description = "Tamanho mínimo do node group"
}

variable "node_max_size" {
  type        = number
  description = "Tamanho máximo do node group"
}

variable "node_desired_size" {
  type        = number
  description = "Tamanho desejado do node group"
}

variable "node_instance_types" {
  type        = list(string)
  description = "Tipos de instância do node group"
}

variable "tags" {
  type        = map(string)
  description = "Tags adicionais para o cluster e nodes"
}
# Storage Module - EFS for persistent data

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs de subnets para EFS"
  type        = list(string)
}

variable "security_group_id" {
  description = "ID del grupo de seguridad"
  type        = string
}
variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "security_group_id" {
  description = "ID del grupo de seguridad"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.medium"
}

variable "ami_id" {
  description = "ID de AMI (Amazon Linux 2023)"
  type        = string
}

variable "dockerhub_username" {
  description = "Usuario de Docker Hub"
  type        = string
  default     = ""
}
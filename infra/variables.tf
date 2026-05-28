variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nombre del ambiente"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "evaluation-devops"
}

variable "frontend_port" {
  description = "Puerto del frontend"
  type        = number
  default     = 80
}

variable "backend_ventas_port" {
  description = "Puerto del backend ventas"
  type        = number
  default     = 8080
}

variable "backend_despachos_port" {
  description = "Puerto del backend despachos"
  type        = number
  default     = 8081
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t2.medium"
}

variable "ami_id" {
  description = "ID de AMI (Amazon Linux 2023 us-east-1)"
  type        = string
  default     = "ami-0df8c184d5f6ae949"
}

variable "dockerhub_username" {
  description = "Usuario de Docker Hub"
  type        = string
  default     = ""
}
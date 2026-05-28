variable "vpc_cidr" {
  description = "Bloque CIDR para la VPC"
  type        = string
}

variable "availability_zone" {
  description = "Zona de disponibilidad para subnets"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}
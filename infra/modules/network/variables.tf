variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "frontend_port" {
  description = "Frontend port"
  type        = number
}

variable "backend_ventas_port" {
  description = "Backend ventas port"
  type        = number
}

variable "backend_despachos_port" {
  description = "Backend despachos port"
  type        = number
}
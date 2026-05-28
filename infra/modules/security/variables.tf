variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "frontend_port" {
  description = "Puerto del frontend"
  type        = number
}

variable "backend_ventas_port" {
  description = "Puerto del backend ventas"
  type        = number
}

variable "backend_despachos_port" {
  description = "Puerto del backend despachos"
  type        = number
}
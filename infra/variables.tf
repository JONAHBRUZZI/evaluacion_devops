variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "evaluation-devops"
}

variable "frontend_port" {
  description = "Frontend port"
  type        = number
  default     = 80
}

variable "backend_ventas_port" {
  description = "Backend ventas port"
  type        = number
  default     = 8080
}

variable "backend_despachos_port" {
  description = "Backend despachos port"
  type        = number
  default     = 8081
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "ami_id" {
  description = "AMI ID (Amazon Linux 2023 us-east-1)"
  type        = string
  default     = "ami-0df8c184d5f6ae949"
}

variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
  default     = ""
}
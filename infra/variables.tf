variable "aws_region" {
  description = "AWS Region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "evaluation-devops"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone" {
  description = "Availability zone for subnets"
  type        = string
  default     = "us-east-1a"
}

variable "frontend_port" {
  description = "Frontend exposed port"
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
  default     = "t3.medium"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
  default     = ""
}

variable "ec2_ssh_key_path" {
  description = "Path to SSH key for EC2 access"
  type        = string
  default     = "~/.ssh/evaluation-devops-key.pem"
}

variable "ami_id" {
  description = "AMI ID for Ubuntu Server LTS (leave empty to use default)"
  type        = string
  default     = ""
}
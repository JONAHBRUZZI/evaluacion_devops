variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "security_group_id" {
  description = "Security Group ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID (Ubuntu Server LTS)"
  type        = string
  default     = ""
}

variable "ssh_key_path" {
  description = "SSH key path"
  type        = string
}

variable "dockerhub_username" {
  description = "Docker Hub username for image pull"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
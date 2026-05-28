variable "project_name" {
  description = "Project name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2"
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
  description = "AMI ID (Ubuntu 24.04 LTS in us-east-1)"
  type        = string
  default     = "ami-04b4f1a9cf54c11d0"
}

variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
  default     = ""
}
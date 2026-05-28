variable "project_name" {
  description = "Project name"
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
  description = "AMI ID (Amazon Linux 2023 or Ubuntu)"
  type        = string
}

variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
  default     = ""
}
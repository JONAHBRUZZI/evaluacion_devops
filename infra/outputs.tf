output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "CIDR of the VPC"
  value       = module.network.vpc_cidr
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = module.network.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = module.network.private_subnet_id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.security.security_group_id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = module.ec2.ec2_public_ip
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.ec2.ec2_private_ip
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = module.ec2.ec2_instance_id
}

output "frontend_url" {
  description = "URL for the frontend service"
  value       = "http://${module.ec2.ec2_public_ip}"
}

output "backend_ventas_url" {
  description = "URL for the backend ventas service"
  value       = "http://${module.ec2.ec2_public_ip}:${var.backend_ventas_port}"
}

output "backend_despachos_url" {
  description = "URL for the backend despachos service"
  value       = "http://${module.ec2.ec2_public_ip}:${var.backend_despachos_port}"
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i <private_key> ubuntu@${module.ec2.ec2_public_ip}"
}

output "ssh_private_key" {
  description = "SSH private key (save to file)"
  value       = module.ec2.ssh_private_key
  sensitive   = true
}

output "ssh_key_warning" {
  description = "Warning about SSH key"
  value       = "Save the ssh_private_key output to a file: terraform output -raw ssh_private_key > evaluation-devops-key.pem && chmod 400 evaluation-devops-key.pem"
}
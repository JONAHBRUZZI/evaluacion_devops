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
  description = "URL for the frontend"
  value       = "http://${module.ec2.ec2_public_ip}"
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh -i ~/.ssh/labsuser.pem ec2-user@${module.ec2.ec2_public_ip}"
}
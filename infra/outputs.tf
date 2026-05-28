output "security_group_id" {
  description = "ID del grupo de seguridad"
  value       = module.security.security_group_id
}

output "ec2_public_ip" {
  description = "IP pública de la instancia EC2"
  value       = module.ec2.ec2_public_ip
}

output "ec2_private_ip" {
  description = "IP privada de la instancia EC2"
  value       = module.ec2.ec2_private_ip
}

output "ec2_instance_id" {
  description = "ID de la instancia EC2"
  value       = module.ec2.ec2_instance_id
}

output "frontend_url" {
  description = "URL del frontend"
  value       = "http://${module.ec2.ec2_public_ip}"
}

output "ssh_command" {
  description = "Comando SSH para conectar"
  value       = "ssh -i ~/.ssh/labsuser.pem ec2-user@${module.ec2.ec2_public_ip}"
}
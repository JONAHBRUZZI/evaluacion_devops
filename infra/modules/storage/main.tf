# Módulo de Almacenamiento - Configuración EFS
resource "aws_efs_file_system" "main" {
  creation_token = var.project_name
  encrypted      = true

  tags = {
    Name = "${var.project_name}-efs"
  }
}

resource "aws_efs_mount_target" "main" {
  count         = length(var.subnet_ids)
  file_system_id = aws_efs_file_system.main.id
  subnet_id      = var.subnet_ids[count.index]
  security_groups = [var.security_group_id]
}

output "efs_id" {
  value = aws_efs_file_system.main.id
}

output "efs_dns_name" {
  value = aws_efs_file_system.main.dns_name
}
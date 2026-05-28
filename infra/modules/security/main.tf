# ============================================
# MÓDULO DE SEGURIDAD
# ============================================
resource "aws_security_group" "main" {
  name_prefix = "${var.project_name}-sg-"
  description = "Grupo de seguridad para el stack evaluation-devops"

  ingress {
    description = "HTTP (Frontend)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend Ventas"
    from_port   = var.backend_ventas_port
    to_port     = var.backend_ventas_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend Despachos"
    from_port   = var.backend_despachos_port
    to_port     = var.backend_despachos_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Todo el tráfico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-security-group"
  }
}

output "security_group_id" {
  value = aws_security_group.main.id
}
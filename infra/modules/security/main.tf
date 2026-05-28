# ============================================
# SECURITY MODULE
# ============================================
resource "aws_security_group" "main" {
  name        = "${var.project_name}-sg"
  description = "Security group for evaluation-devops stack"

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
    description = "Backend Ventas (Internal)"
    from_port   = var.backend_ventas_port
    to_port     = var.backend_ventas_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend Despachos (Internal)"
    from_port   = var.backend_despachos_port
    to_port     = var.backend_despachos_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
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
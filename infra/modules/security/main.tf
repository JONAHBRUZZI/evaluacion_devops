# ============================================
# SECURITY MODULE
# ============================================
# Creates Security Groups with least privilege

resource "aws_security_group" "main" {
  name        = "${var.project_name}-sg"
  description = "Security group for evaluation-devops stack"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP (Frontend)"
    from_port   = var.frontend_port
    to_port     = var.frontend_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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
    description = "Backend Ventas (Internal Only)"
    from_port   = var.backend_ventas_port
    to_port     = var.backend_ventas_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "Backend Despachos (Internal Only)"
    from_port   = var.backend_despachos_port
    to_port     = var.backend_despachos_port
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
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
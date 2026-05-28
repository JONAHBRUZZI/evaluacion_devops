# ============================================
# EC2 MODULE - Learner Lab compatible
# ============================================
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = data.aws_subnets.default.ids[0]

  vpc_security_group_ids = [var.security_group_id]
  key_name               = "vockey"

  associate_public_ip_address = true

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  user_data = templatefile("${path.module}/user-data.sh", {
    DOCKERHUB_USERNAME = var.dockerhub_username
    PROJECT_NAME       = var.project_name
  })

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

output "ec2_instance_id" {
  value = aws_instance.main.id
}

output "ec2_public_ip" {
  value = aws_instance.main.public_ip
}

output "ec2_private_ip" {
  value = aws_instance.main.private_ip
}
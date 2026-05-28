# ============================================
# EC2 MODULE
# ============================================
# Creates EC2 instance with Docker and Docker Compose

data "aws_ami" "ubuntu" {
  count = var.ami_id == "" ? 1 : 0

  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.project_name}-key-${random_string.suffix.result}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_instance" "main" {
  ami           = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu[0].id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id

  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.ssh_key.key_name

  associate_public_ip_address = true

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
    encrypted   = true
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

output "ec2_ami" {
  value = aws_instance.main.ami
}

output "ssh_private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
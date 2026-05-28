# ============================================
# MAIN TERRAFORM CONFIGURATION
# ============================================
# Evaluation DevOps - AWS Infrastructure

module "network" {
  source = "./modules/network"

  vpc_cidr          = var.vpc_cidr
  availability_zone = var.availability_zone
  project_name      = var.project_name
}

module "security" {
  source = "./modules/security"

  vpc_id                = module.network.vpc_id
  project_name          = var.project_name
  frontend_port         = var.frontend_port
  backend_ventas_port   = var.backend_ventas_port
  backend_despachos_port = var.backend_despachos_port
}

module "ec2" {
  source = "./modules/ec2"

  project_name        = var.project_name
  vpc_id              = module.network.vpc_id
  subnet_id          = module.network.public_subnet_id
  security_group_id   = module.security.security_group_id
  instance_type       = var.instance_type
  ami_id             = var.ami_id
  ssh_key_path       = var.ec2_ssh_key_path
  dockerhub_username = var.dockerhub_username
}
# ============================================
# MAIN TERRAFORM - Learner Lab compatible
# ============================================
module "security" {
  source = "./modules/security"

  project_name          = var.project_name
  frontend_port         = var.frontend_port
  backend_ventas_port   = var.backend_ventas_port
  backend_despachos_port = var.backend_despachos_port
}

module "ec2" {
  source = "./modules/ec2"

  project_name        = var.project_name
  security_group_id   = module.security.security_group_id
  instance_type       = var.instance_type
  ami_id             = var.ami_id
  dockerhub_username = var.dockerhub_username
}
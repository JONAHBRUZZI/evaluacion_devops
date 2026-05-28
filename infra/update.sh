#!/bin/bash
# ============================================
# UPDATE SCRIPT
# ============================================
# Updates frontend on running EC2 instance

set -e

echo "============================================"
echo "  EVALUATION DEVOPS - UPDATE FRONTEND"
echo "============================================"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get EC2 IP from terraform output
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -f .terraform/terraform.tfstate ]; then
    print_error "Terraform state not found. Run deploy.sh first"
    exit 1
fi

EC2_IP=$(terraform output -raw ec2_public_ip 2>/dev/null)

if [ -z "$EC2_IP" ]; then
    print_error "Could not get EC2 public IP"
    exit 1
fi

print_status "EC2 Public IP: $EC2_IP"

print_status "Pulling latest frontend image..."
docker --tls-arg --host=unix:///var/run/docker.sock pull evaluation-devops-frontend:latest 2>/dev/null || \
ssh -o StrictHostKeyChecking=no -i ~/.ssh/evaluation-devops-key.pem ubuntu@$EC2_IP "docker pull evaluation-devops-frontend:latest" || {
    print_warning "Could not pull image. Make sure SSH key is configured"
}

print_status "Restarting frontend container..."
ssh -o StrictHostKeyChecking=no -i ~/.ssh/evaluation-devops-key.pem ubuntu@$EC2_IP "cd /app && docker compose up -d frontend"

print_status "=========================================="
print_status "  Frontend updated successfully"
print_status "=========================================="
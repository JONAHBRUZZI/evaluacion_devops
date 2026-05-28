#!/bin/bash
# ============================================
# DEPLOY SCRIPT
# ============================================
# Deploys infrastructure and application to AWS

set -e

echo "============================================"
echo "  EVALUATION DEVOPS - DEPLOYMENT"
echo "============================================"

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print status
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed"
    exit 1
fi

print_status "Initializing Terraform..."
terraform init

print_status "Formatting Terraform files..."
terraform fmt

print_status "Validating Terraform configuration..."
terraform validate || {
    print_error "Terraform validation failed"
    exit 1
}

print_status "Creating execution plan..."
terraform plan -out=tfplan

print_warning "=========================================="
print_warning "  About to apply infrastructure changes"
print_warning "  This will create AWS resources"
print_warning "=========================================="

read -p "Continue? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Deployment cancelled"
    exit 0
fi

print_status "Applying Terraform configuration..."
terraform apply tfplan

print_status "=========================================="
print_status "  Infrastructure deployed successfully"
print_status "=========================================="

# Show outputs
echo ""
print_status "Deployment Outputs:"
terraform output

echo ""
print_status "Next steps:"
echo "  1. Wait 2-3 minutes for EC2 user-data to complete"
echo "  2. SSH to instance and run: ssh -i ~/.ssh/evaluation-devops-key.pem ubuntu@<public-ip>"
echo "  3. Pull Docker images: cd /app && docker compose pull"
echo "  4. Start services: cd /app && ./start.sh"

echo ""
print_status "Or wait for GitHub Actions to deploy automatically"
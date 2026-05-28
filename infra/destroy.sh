#!/bin/bash
# ============================================
# DESTROY SCRIPT
# ============================================
# Destroys all AWS infrastructure

set -e

echo "============================================"
echo "  EVALUATION DEVOPS - DESTRUCTION"
echo "============================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

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

if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed"
    exit 1
fi

print_warning "=========================================="
print_warning "  WARNING: This will destroy ALL resources"
print_warning "  - VPC, Subnets, Security Groups"
print_warning "  - EC2 Instance"
print_warning "  - All data will be lost"
print_warning "=========================================="

read -p "Type 'destroy' to confirm: " -r
echo
if [[ ! $REPLY == "destroy" ]]; then
    print_status "Destruction cancelled"
    exit 0
fi

print_status "Initializing Terraform..."
terraform init

print_status "Destroying infrastructure..."
terraform destroy -auto-approve

print_status "=========================================="
print_status "  Infrastructure destroyed"
print_status "=========================================="
#!/bin/bash
# ============================================
# SCRIPT DE ACTUALIZACIÓN
# ============================================

set -e

echo "============================================"
echo "  EVALUACIÓN DEVOPS - ACTUALIZAR FRONTEND"
echo "============================================"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

imprimir_estado() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

imprimir_aviso() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

imprimir_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -f .terraform/terraform.tfstate ]; then
    imprimir_error "Estado de Terraform no encontrado. Ejecuta deploy.sh primero"
    exit 1
fi

EC2_IP=$(terraform output -raw ec2_public_ip 2>/dev/null)

if [ -z "$EC2_IP" ]; then
    imprimir_error "No se pudo obtener la IP pública de EC2"
    exit 1
fi

imprimir_estado "IP pública de EC2: $EC2_IP"

imprimir_estado "Actualizando contenedor frontend..."
ssh -o StrictHostKeyChecking=no -i ~/.ssh/labsuser.pem ec2-user@$EC2_IP "cd /app && sudo docker pull evaluation-devops-frontend:latest && sudo docker-compose up -d frontend"

imprimir_estado "=========================================="
imprimir_estado "  Frontend actualizado exitosamente"
imprimir_estado "=========================================="
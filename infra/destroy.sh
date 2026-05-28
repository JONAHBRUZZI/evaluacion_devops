#!/bin/bash
# ============================================
# SCRIPT DE DESTRUCCIÓN
# ============================================

set -e

echo "============================================"
echo "  EVALUACIÓN DEVOPS - DESTRUCCIÓN"
echo "============================================"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

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

if ! command -v terraform &> /dev/null; then
    imprimir_error "Terraform no está instalado"
    exit 1
fi

imprimir_aviso "=========================================="
imprimir_aviso "  ADVERTENCIA: Se destruirán TODOS los recursos"
imprimir_aviso "  - VPC, Subnets, Grupos de Seguridad"
imprimir_aviso "  - Instancia EC2"
imprimir_aviso "  - Todos los datos se perderán"
imprimir_aviso "=========================================="

read -p "Escribe 'destruir' para confirmar: " -r
echo
if [[ ! $REPLY == "destruir" ]]; then
    imprimir_estado "Destrucción cancelada"
    exit 0
fi

imprimir_estado "Inicializando Terraform..."
terraform init

imprimir_estado "Destruyendo infraestructura..."
terraform destroy -auto-approve

imprimir_estado "=========================================="
imprimir_estado "  Infraestructura destruida"
imprimir_estado "=========================================="
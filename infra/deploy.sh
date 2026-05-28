#!/bin/bash
# ============================================
# SCRIPT DE DESPLIEGUE
# ============================================

set -e

echo "============================================"
echo "  EVALUACIÓN DEVOPS - DESPLIEGUE"
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

imprimir_estado "Inicializando Terraform..."
terraform init

imprimir_estado "Formateando archivos Terraform..."
terraform fmt

imprimir_estado "Validando configuración de Terraform..."
terraform validate || {
    imprimir_error "Validación de Terraform falló"
    exit 1
}

imprimir_estado "Creando plan de ejecución..."
terraform plan -out=tfplan

imprimir_aviso "=========================================="
imprimir_aviso "  Se aplicarán cambios en infraestructura"
imprimir_aviso "  Se crearán recursos de AWS"
imprimir_aviso "=========================================="

read -p "¿Continuar? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    imprimir_estado "Despliegue cancelado"
    exit 0
fi

imprimir_estado "Aplicando configuración de Terraform..."
terraform apply tfplan

imprimir_estado "=========================================="
imprimir_estado "  Infraestructura desplegada exitosamente"
imprimir_estado "=========================================="

echo ""
imprimir_estado "Resultados del despliegue:"
terraform output

echo ""
imprimir_estado "Próximos pasos:"
echo "  1. Esperar 2-3 minutos para que el user-data de EC2 termine"
echo "  2. Conectar por SSH: ssh -i ~/.ssh/labsuser.pem ec2-user@<ip-publica>"
echo "  3. Las imágenes Docker se despliegan automáticamente desde GitHub Actions"
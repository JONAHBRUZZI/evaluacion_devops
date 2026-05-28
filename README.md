# Evaluacion DevOps - Sistema Fullstack

## Descripción General

Proyecto fullstack containerizado para evaluación académica de DevOps. Incluye frontend React y backends Spring Boot desplegados en AWS EC2 usando Terraform e infraestructura como código.

## Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Cloud                                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                      VPC (10.0.0.0/16)                    │  │
│  │                                                            │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │           EC2 Instance (Ubuntu Server LTS)          │  │  │
│  │  │                                                      │  │  │
│  │  │  ┌─────────────────────────────────────────────┐     │  │  │
│  │  │  │         Docker Containers                    │     │  │  │
│  │  │  │  ┌──────────┐ ┌────────────┐ ┌────────────┐ │     │  │  │
│  │  │  │  │ Frontend │ │ Backend    │ │ Backend    │ │     │  │  │
│  │  │  │  │ (Nginx)  │ │ Ventas     │ │ Despachos  │ │     │  │  │
│  │  │  │  │  :80     │ │  :8080     │ │  :8081     │ │     │  │  │
│  │  │  │  └──────────┘ └────────────┘ └────────────┘ │     │  │  │
│  │  │  └─────────────────────────────────────────────┘     │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## Componentes

| Componente | Tecnología | Puerto | Descripción |
|------------|-------------|--------|-------------|
| Frontend | React 18, Vite 5, Tailwind CSS | 80 | Aplicación web pública |
| Backend Ventas | Spring Boot 3.4.4, Java 17 | 8080 | API REST para ventas (privado) |
| Backend Despachos | Spring Boot 3.4.4, Java 17 | 8081 | API REST para despachos (privado) |

## Stack Tecnológico

- **Frontend**: React 18.2, Vite 5.2, Tailwind CSS 3.4, React Router 6.24
- **Backend**: Spring Boot 3.4.4, Java 17 (Eclipse Temurin)
- **Contenedores**: Docker 24+, Docker Compose
- **Infraestructura**: Terraform 1.6+, AWS EC2
- **CI/CD**: GitHub Actions
- **Registro**: Docker Hub

## Estructura del Proyecto

```
evaluacion_devops/
├── front_despacho/           # React frontend
│   ├── Dockerfile            # Multi-stage build
│   ├── nginx.conf            # Nginx configuration
│   └── package.json
├── back-Ventas_SpringBoot/   # Spring Boot backend (ventas)
│   ├── Dockerfile            # Multi-stage build
│   └── Springboot-API-REST/
├── back-Despachos_SpringBoot/ # Spring Boot backend (despachos)
│   ├── Dockerfile            # Multi-stage build
│   └── Springboot-API-REST-DESPACHO/
├── infra/                    # Terraform infrastructure
│   ├── modules/
│   │   ├── network/          # VPC, subnets, gateways
│   │   ├── security/         # Security groups
│   │   ├── ec2/              # EC2 instance
│   │   └── storage/          # EFS (optional)
│   ├── deploy.sh             # Deploy script
│   ├── destroy.sh            # Destroy script
│   └── update.sh             # Update script
├── .github/workflows/         # GitHub Actions
│   └── deploy.yml            # CI/CD pipeline
├── docs/                     # Documentación
│   ├── architecture.md
│   ├── devops-explanation.md
│   └── evidence.md
├── docker-compose.yml         # Docker Compose para local
├── .env.example              # Variables de entorno ejemplo
└── README.md
```

## Instalación Local

### Prerrequisitos
- Docker 24+
- Docker Compose
- Node.js 20+ (para desarrollo frontend)
- Java 17+ (para desarrollo backend)

### Desarrollo Local

```bash
# 1. Clonar el repositorio
git clone git@github.com:JONAHBRUZZI/evaluacion_devops.git
cd evaluacion_devops

# 2. Configurar variables de entorno
cp .env.example .env
# Editar .env con valores reales

# 3. Iniciar con Docker Compose
docker-compose up -d

# 4. Verificar servicios
docker-compose ps
```

### Desarrollo Frontend

```bash
cd front_despacho
npm install
npm run dev
```

### Desarrollo Backend

```bash
# Backend Ventas
cd back-Ventas_SpringBoot/Springboot-API-REST
./mvnw spring-boot:run

# Backend Despachos
cd back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO
./mvnw spring-boot:run
```

## Variables de Entorno

| Variable | Descripción | Valor Ejemplo |
|----------|-------------|---------------|
| `DB_ENDPOINT` | Endpoint de base de datos MySQL | localhost |
| `DB_PORT` | Puerto de MySQL | 3306 |
| `DB_NAME` | Nombre de la base de datos | evaluation_devops |
| `DB_USERNAME` | Usuario de base de datos | root |
| `DB_PASSWORD` | Contraseña de base de datos | *** |
| `DOCKERHUB_USERNAME` | Usuario de Docker Hub | your-username |
| `DOCKERHUB_TOKEN` | Token de Docker Hub | *** |
| `AWS_REGION` | Región de AWS | us-east-1 |

## Docker

### Construir Imágenes

```bash
# Frontend
docker build -f front_despacho/Dockerfile -t evaluation-devops-frontend ./front_despacho

# Backend Ventas
docker build -f back-Ventas_SpringBoot/Dockerfile -t evaluation-devops-backend-ventas ./back-Ventas_SpringBoot

# Backend Despachos
docker build -f back-Despachos_SpringBoot/Dockerfile -t evaluation-devops-backend-despachos ./back-Despachos_SpringBoot
```

### Docker Compose

```bash
# Iniciar todos los servicios
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener servicios
docker-compose down

# Reconstruir imágenes
docker-compose up -d --build
```

## Terraform

### Despliegue de Infraestructura

```bash
cd infra

# Desplegar infraestructura
./deploy.sh

# Ver plan sin aplicar
terraform plan

# Aplicar cambios
terraform apply

# Destruir todo
./destroy.sh
```

### Outputs de Terraform

Después del despliegue, Terraform muestra:
- `ec2_public_ip`: IP pública del servidor
- `frontend_url`: URL del frontend
- `ssh_command`: Comando SSH para conectar

## AWS EC2

### Configuración de Seguridad

| Puerto | Servicio | Acceso |
|--------|----------|--------|
| 22 | SSH | 0.0.0.0/0 |
| 80 | HTTP (Frontend) | 0.0.0.0/0 |
| 443 | HTTPS | 0.0.0.0/0 |
| 8080 | Backend Ventas | 10.0.0.0/16 |
| 8081 | Backend Despachos | 10.0.0.0/16 |

### Conexión SSH

```bash
ssh -i ~/.ssh/evaluation-devops-key.pem ubuntu@<ec2-public-ip>
```

### En el EC2

```bash
# Ver contenedores
docker ps

# Ver logs
docker logs evaluation-devops-frontend
docker logs evaluation-devops-backend-ventas
docker logs evaluation-devops-backend-despachos

# Reiniciar servicio
docker compose -f /app/docker-compose.yml restart frontend

# Actualizar imágenes
docker compose -f /app/docker-compose.yml pull
docker compose -f /app/docker-compose.yml up -d
```

## CI/CD con GitHub Actions

### Pipeline

El pipeline de GitHub Actions se ejecuta al hacer push a la rama `deploy`:

1. **Validación**: ESLint, build de frontend, build de backends
2. **Build Docker**: Construye las 3 imágenes
3. **Push a Docker Hub**: Publica imágenes
4. **Terraform Apply**: Despliega infraestructura
5. **Deploy a EC2**: Actualiza contenedores
6. **Health Checks**: Verifica servicios

### Secrets Requeridos

Configurar en GitHub Settings → Secrets:

| Secret | Descripción |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Key |
| `AWS_SESSION_TOKEN` | AWS Session Token (si usa rol) |
| `AWS_REGION` | Región de AWS |
| `DOCKERHUB_USERNAME` | Usuario de Docker Hub |
| `DOCKERHUB_TOKEN` | Token de Docker Hub |
| `DB_PASSWORD` | Contraseña de base de datos |
| `EC2_SSH_KEY` | Clave privada SSH para EC2 |

## Persistencia

### Volúmenes Docker

```yaml
volumes:
  frontend-data: /usr/share/nginx/html
  # Para agregar persistencia de BD:
  # db-data: /var/lib/mysql
```

### Datos que Persisten

| Volumen | Datos | Survive a |
|---------|-------|------------|
| frontend-data | Archivos estáticos | Reinicio de contenedor |
| db-data (opcional) | Datos MySQL | Reinicio de contenedor |

### Datos que NO Persisten

- Sistema de archivos del contenedor
- Logs (stdout/stderr)
- Configuración en memoria

### Recomendación para Producción

Para persistencia robusta:
- Usar AWS RDS para base de datos
- Usar AWS EFS para archivos
- Configurar backups automáticos

## Seguridad

### Medidas Implementadas

1. **Contenedores no root**: Todos los contenedores usan usuarios sin privilegios
2. **Security Groups**: Solo puertos necesarios expuestos
3. **Redes privadas**: Backends no accesibles desde internet
4. **Secrets externos**: Credenciales via variables de entorno
5. **Nginx hardening**: Headers de seguridad configurados

### Puertos Expuestos

| Servicio | Puerto | Público |
|----------|--------|---------|
| Frontend | 80 | Sí |
| Backend Ventas | 8080 | No (solo red interna) |
| Backend Despachos | 8081 | No (solo red interna) |

## Troubleshooting

### Frontend no carga

```bash
# Verificar logs
docker logs evaluation-devops-frontend

# Verificar red
docker network inspect evaluation_devops_evaluation-network

# Verificar healthcheck
curl http://localhost:80/
```

### Backend no responde

```bash
# Verificar logs
docker logs evaluation-devops-backend-ventas
docker logs evaluation-devops-backend-despachos

# Verificar healthcheck
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health

# Verificar conexión a BD
docker exec evaluation-devops-backend-ventas env | grep DB_
```

### Terraform issues

```bash
# Ver estado
cd infra
terraform show

# Refrescar estado
terraform refresh

# Liberar lock si hay problema
terraform force-unlock <lock-id>
```

## Comandos Rápidos

```bash
# Docker Compose
docker-compose up -d          # Iniciar
docker-compose down          # Detener
docker-compose logs -f       # Ver logs
docker-compose ps            # Ver estado
docker-compose build         # Reconstruir

# Terraform
cd infra && ./deploy.sh      # Desplegar
cd infra && ./destroy.sh     # Destruir
cd infra && ./update.sh      # Actualizar frontend

# GitHub Actions
git checkout -b deploy       # Crear rama deploy
git push origin deploy       # Trigger pipeline
```

## Documentación Adicional

- [Arquitectura](docs/architecture.md) - Diagrama detallado de arquitectura
- [DevOps Explained](docs/devops-explanation.md) - Justificación técnica de decisiones
- [Evidence Guide](docs/evidence.md) - Guía para defensa académica
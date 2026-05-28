# ============================================
# DOCUMENTACIÓN DE EXPLICACIÓN DEVOPS
# ============================================

# 1. Diseño de Contenedorización

## Frontend (React + Vite + Nginx)

### Estrategia de Build Multi-etapa
```
Etapa 1: Builder (node:20-alpine)
├── Instalar dependencias (npm ci)
├── Copiar código fuente
├── Compilar bundle de producción (npm run build)
└── Salida: /app/dist

Etapa 2: Producción (nginx:alpine)
├── Copiar artefactos de build desde builder
├── Configuración personalizada de nginx
├── Establecer permisos de archivos adecuados
└── Ejecutar como usuario no-root (nginx)
```

### Implementación de Seguridad
- **Usuario no-root**: usuario nginx (uid 101)
- **Sistema de archivos de solo lectura**: Configurado mediante nginx.conf
- **Imagen mínima**: Basada en Alpine (~15MB base)
- **Healthcheck**: Verificación HTTP cada 30s

### Optimización de Rendimiento
- **Caché de capas**: Dependencias instaladas antes de copiar código
- **Nginx gzip**: Compresión para archivos de texto
- **Archivos estáticos**: Servidos directamente desde nginx, sin sobrecarga de node
- **Caché de assets**: URLs inmutables para archivos con hash

### Compatibilidad con AWS
- **Puerto 80 expuesto**: HTTP estándar para security groups de EC2
- **Endpoint de healthcheck**: / retorna 200 para integración con ELB/ALB
- **Superficie de ataque mínima**: Sin shell, sin gestores de paquetes en la imagen final

## Backend Ventas (Spring Boot)

### Estrategia de Build Multi-etapa
```
Etapa 1: Builder (eclipse-temurin:17-jdk-alpine)
├── Copiar pom.xml
├── Descargar dependencias Maven
├── Copiar código fuente
├── Compilar JAR (./mvnw package)
└── Salida: /app/target/*.jar

Etapa 2: Producción (eclipse-temurin:17-jre-alpine)
├── Crear usuario no-root (appuser:appgroup)
├── Copiar JAR desde builder
├── Establecer permisos adecuados
└── Ejecutar como usuario no-root
```

### Implementación de Seguridad
- **Ejecución no-root**: appuser (uid 1001)
- **Sin acceso a shell**: Solo el proceso Java en ejecución
- **Sistema de archivos de solo lectura**: solo /app, logs a stdout
- **Healthcheck**: Endpoint de Actuator cada 30s

### Compatibilidad con AWS
- **Java 17 LTS**: Compatible con Amazon Corretto
- **Actuator health**: /actuator/health para monitoreo
- **Variables de entorno**: Soporte nativo de Spring para secrets de AWS
- **Puerto 8080**: Solo interno, no expuesto a internet

## Backend Despachos (Spring Boot)

Misma arquitectura que Ventas, con:
- **Puerto 8081**: Diferente de Ventas para permitir despliegue en paralelo
- **Contenedor separado**: Capacidad de escalado independiente
- **Red compartida**: Comunicación mediante DNS de Docker

# 2. Arquitectura de Docker Compose

## Definiciones de Servicios

### Servicio Frontend
```yaml
image: evaluation-devops-frontend:latest
ports:
  - "80:80"           # Acceso público
networks:
  - evaluation-network
depends_on:
  - backend-ventas    # Condición de healthcheck
  - backend-despachos # Condición de healthcheck
restart: unless-stopped
healthcheck:
  test: ["CMD", "wget", "-q", "http://localhost:80/"]
```

### Servicio Backend Ventas
```yaml
image: evaluation-devops-backend-ventas:latest
ports:
  - "8080:8080"       # Solo interno
environment:
  - DB_ENDPOINT=${DB_ENDPOINT}
  - DB_PASSWORD=${DB_PASSWORD}
networks:
  - evaluation-network
restart: unless-stopped
healthcheck:
  test: ["CMD", "wget", "-q", "http://localhost:8080/actuator/health"]
```

### Servicio Backend Despachos
```yaml
image: evaluation-devops-backend-despachos:latest
ports:
  - "8081:8081"       # Solo interno
environment:
  - DB_ENDPOINT=${DB_ENDPOINT}
  - DB_PASSWORD=${DB_PASSWORD}
networks:
  - evaluation-network
restart: unless-stopped
healthcheck:
  test: ["CMD", "wget", "-q", "http://localhost:8081/actuator/health"]
```

## Arquitectura de Red

```
┌─────────────────────────────────────────────────┐
│           evaluation-network (bridge)           │
│                                                 │
│   Driver: bridge                                │
│   Subnet: 172.20.0.0/16                        │
│                                                 │
│   Resolución DNS:                             │
│   ├── frontend → 172.20.0.2                   │
│   ├── backend-ventas → 172.20.0.3             │
│   └── backend-despachos → 172.20.0.4           │
│                                                 │
│   Frontend puede alcanzar backends por nombre:         │
│   • http://backend-ventas:8080                 │
│   • http://backend-despachos:8081              │
└─────────────────────────────────────────────────┘
```

## Estrategia de Persistencia

### Configuración de Volúmenes
```yaml
volumes:
  - frontend-data:/usr/share/nginx/html
  - db-data:/var/lib/mysql

volumes:
  frontend-data:
    driver: local
  db-data:
    driver: local
```

### Qué Persiste
| Volumen | Datos | Sobrevive |
|--------|------|----------|
| frontend-data | Archivos subidos, caché | Reinicio de contenedor |
| db-data | Archivos de base de datos | Reinicio de contenedor |

### Qué No Persiste
- Sistema de archivos del contenedor (código, configs)
- Directorios tmp
- Logs (stdout)

### Protección de Datos
- Los volúmenes sobreviven a `docker compose down`
- Los volúmenes sobreviven a `docker compose up -d`
- Los volúmenes NO sobreviven a `docker compose down -v`
- Se recomienda EBS para base de datos en producción

# 3. Explicación del Pipeline CI/CD

## Activación del Pipeline

```yaml
on:
  push:
    branches:
      - deploy
```

Cuando se hace push del código a la rama `deploy`:
1. GitHub Actions se activa automáticamente
2. Se ejecuta el pipeline completo
3. No se requiere intervención manual

## Etapas del Pipeline

### Etapa 1: Validación
```
├── Obtener código
├── Instalar dependencias (npm ci)
├── ESLint (calidad de código)
└── Build (verificación de compilación)
```

### Etapa 2: Compilar Backends
```
├── Backend Ventas
│   ├── Configurar Java 17
│   └── Maven package
│
└── Backend Despachos
    ├── Configurar Java 17
    └── Maven package
```

### Etapa 3: Build y Push de Docker
```
├── Iniciar sesión en Docker Hub
├── Construir imagen frontend
├── Publicar imagen frontend
├── Construir imagen backend-ventas
├── Publicar imagen backend-ventas
├── Construir imagen backend-despachos
└── Publicar imagen backend-despachos
```

### Etapa 4: Despliegue con Terraform
```
├── Configurar credenciales de AWS
├── Terraform init
├── Terraform fmt
├── Terraform validate
├── Terraform plan
└── Terraform apply
```

### Etapa 5: Despliegue en EC2
```
├── Esperar inicialización de EC2 (2 min)
├── Conectar vía SSH a EC2
├── Iniciar sesión en Docker Hub
├── Descargar últimas imágenes
├── Detener contenedores existentes
└── Iniciar nuevos contenedores
```

### Etapa 6: Verificación de Salud
```
├── Verificar frontend (/ puerto 80)
├── Verificar backend-ventas (/actuator/health)
├── Verificar backend-despachos (/actuator/health)
└── Reportar estado
```

## Configuración de Secrets

GitHub Secrets requeridos:
| Secret | Propósito |
|--------|---------|
| AWS_ACCESS_KEY_ID | Autenticación de AWS |
| AWS_SECRET_ACCESS_KEY | Autenticación de AWS |
| AWS_SESSION_TOKEN | Sesión temporal de AWS |
| AWS_REGION | Región objetivo |
| DOCKERHUB_USERNAME | Autenticación para publicar imágenes |
| DOCKERHUB_TOKEN | Autenticación para publicar imágenes |
| DB_PASSWORD | Contraseña de base de datos del backend |
| EC2_SSH_KEY | Acceso SSH a EC2 |

## Justificación de Docker Hub

¿Por qué Docker Hub y no ECR/otros registries?

1. **Simplicidad**: Sin configuración de registry en el pipeline
2. **Capa gratuita**: Repos públicos ilimitados, 1 privado
3. **Madurez**: Estándar de la industria, bien documentado
4. **Integración**: Soporte nativo de `docker/login-action`
5. **Velocidad**: CDN global, descargas rápidas en todo el mundo
6. **Costo**: Sin tarifas de salida para imágenes públicas

Para producción con imágenes sensibles:
- AWS ECR con VPC endpoints
- Azure Container Registry
- Google Artifact Registry

# 4. Principios DevOps Aplicados

## Infraestructura como Código (IaC)

**Beneficios de Terraform**:
- Infraestructura con control de versiones
- Despliegues reproducibles
- Entornos consistentes
- Destrucción y recreación rápidas
- Seguimiento de estado y versionado

**Implementación**:
```bash
# Desplegar
./deploy.sh

# Destruir
./destroy.sh
```

## Contenedorización (Docker)

**Beneficios**:
- Entornos consistentes (dev = prod)
- Aislamiento entre servicios
- Límites y asignación de recursos
- Escalado rápido
- Capacidad de rollback

**Implementación**:
- Builds multi-etapa
- Usuarios no-root
- Healthchecks
- Restricciones de recursos

## Integración y Despliegue Continuo (CI/CD)

**Beneficios**:
- Pruebas automatizadas
- Despliegues consistentes
- Ciclo de retroalimentación rápido
- Reducción de errores humanos
- Trazabilidad de auditoría

**Implementación**:
- GitHub Actions
- Activadores automáticos
- Promoción entre entornos
- Verificaciones de salud

## Infraestructura Inmutable

**Principio**: Nunca modificar instancias en ejecución, siempre reemplazar

**Implementación**:
- Nueva AMI/imagen para cambios
- Despliegues blue-green
- Infraestructura como código
- Contenedores versionados

## Seguridad por Diseño

**Implementación**:
- Contenedores no-root
- Security groups de privilegio mínimo
- Sin secrets hardcodeados
- Secrets mediante variables de entorno
- Segmentación de red (subredes públicas/privadas)

## Consideraciones de Escalabilidad

**Escalado Horizontal**:
- Servicios sin estado
- Base de datos externa
- Preparado para balanceador de carga

**Escalado Vertical**:
- t3.medium por defecto (ajustable)
- Expansión de volumen EBS
- Límites de recursos Docker

## Monitoreo y Health Checks

**Endpoints de Salud**:
- Frontend: `http://localhost:80/`
- Backend Ventas: `http://localhost:8080/actuator/health`
- Backend Despachos: `http://localhost:8081/actuator/health`

**Verificaciones Automatizadas**:
- Docker healthcheck
- Paso de health en GitHub Actions
- Preparado para integración con ELB/ALB

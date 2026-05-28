# ============================================
# GUÍA DE EVIDENCIAS PARA DEFENSA ACADÉMICA
# ============================================

# Lista de Verificación de Evidencias

## Evidencias de GitHub Actions

### 1. Ejecución del Workflow
- [ ] GitHub Actions activado al hacer push en la rama `deploy`
- [ ] Todos los jobs completados exitosamente
- [ ] Capturas de pantalla del estado de cada job

### 2. Etapa de Validación
- [ ] ESLint aprobado
- [ ] Build del frontend exitoso
- [ ] Build Maven del backend exitoso

### 3. Build y Push de Docker
- [ ] Imágenes construidas exitosamente
- [ ] Imágenes publicadas en Docker Hub
- [ ] Tags visibles en Docker Hub

### 4. Despliegue con Terraform
- [ ] Terraform init exitoso
- [ ] Salida de terraform plan
- [ ] Terraform apply completado
- [ ] Instancia EC2 creada

### 5. Despliegue en EC2
- [ ] Conexión SSH exitosa
- [ ] Imágenes Docker descargadas
- [ ] Contenedores iniciados

### 6. Verificación de Salud
- [ ] Frontend retornando 200
- [ ] Backends retornando 200

## Evidencias de Terraform

### 1. Archivos de Estado
- [ ] terraform.tfstate existe
- [ ] El estado contiene todos los recursos
- [ ] Estado bloqueado (si se usa backend remoto)

### 2. Salida del Plan
- [ ] Recursos a crear
- [ ] Recursos a modificar
- [ ] Recursos a destruir

### 3. Salida del Apply
- [ ] IP pública mostrada
- [ ] Todos los recursos creados
- [ ] Sin errores

## Evidencias de Docker

### 1. Pruebas Locales
```bash
# Construir imágenes
docker build -f front_despacho/Dockerfile -t test-frontend ./front_despacho
docker build -f back-Ventas_SpringBoot/Dockerfile -t test-backend-ventas ./back-Ventas_SpringBoot
docker build -f back-Despachos_SpringBoot/Dockerfile -t test-backend-despachos ./back-Despachos_SpringBoot

# Ejecutar compose
docker-compose up -d

# Verificar contenedores
docker ps

# Ver logs
docker-compose logs -f
```

### 2. Estado de los Contenedores
- [ ] Todos los contenedores en ejecución
- [ ] Sin reinicios (healthcheck aprobado)
- [ ] Puertos correctos expuestos

### 3. Verificación de Red
```bash
# Ver redes
docker network ls
docker network inspect evaluation_devops_evaluation-network
```

### 4. Verificación de Volúmenes
```bash
# Listar volúmenes
docker volume ls

# Inspeccionar volumen
docker volume inspect evaluation_devops_frontend-data
```

## Evidencias de AWS EC2

### 1. Instancia Creada
- [ ] Instancia EC2 en ejecución
- [ ] IP pública asignada
- [ ] Security groups configurados

### 2. Acceso SSH
```bash
ssh -i ~/.ssh/evaluation-devops-key.pem ubuntu@<public-ip>
```

### 3. Instalación de Docker
```bash
docker --version
docker compose version
```

### 4. Contenedores en Ejecución
```bash
docker ps
docker compose -f /app/docker-compose.yml ps
```

### 5. Servicios Accesibles
```bash
curl http://localhost
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
```

## Evidencias de Red

### Security Groups
- Puerto 80 (HTTP) abierto a 0.0.0.0/0
- Puerto 443 (HTTPS) abierto a 0.0.0.0/0
- Puerto 22 (SSH) abierto a 0.0.0.0/0
- Puertos 8080, 8081 abiertos solo a 10.0.0.0/16

### Configuración de VPC
- VPC con CIDR 10.0.0.0/16
- Subred pública (10.0.1.0/24)
- Subred privada (10.0.2.0/24)
- Internet Gateway adjunto
- Tablas de ruteo configuradas

## Evidencias de Persistencia

### 1. Creación de Volumen
```bash
docker volume create test-volume
docker volume inspect test-volume
```

### 2. Prueba de Supervivencia de Datos
```bash
# Crear datos
docker exec container mkdir /data/test
docker exec container touch /data/test/file.txt

# Reiniciar contenedor
docker restart container

# Verificar que los datos existen
docker exec container ls /data/test
```

### 3. Datos en Producción
- [ ] Datos de base de datos persisten
- [ ] Archivos subidos persisten
- [ ] Configuración persiste

## Problemas Comunes y Solución de Problemas

### Fallo en Build de Docker
```
Problema: Build multi-etapa falla
Solución: Verificar rutas COPY, asegurar que los archivos existen
```

### El Contenedor No Inicia
```
Problema: Puerto ya en uso
Solución: Verificar otros contenedores usando el mismo puerto
```

### Fallo en Healthcheck
```
Problema: Servicio no responde
Solución: Verificar logs, comprobar mapeo de puertos
```

### Estado de Terraform Bloqueado
```
Problema: Estado bloqueado por otro proceso
Solución: terraform force-unlock <lock-id>
```

### Timeout de SSH a EC2
```
Problema: No se puede conectar a EC2
Solución: Verificar security group, comprobar permisos de llave
```

# Respuestas para la Defensa

## Preguntas de Arquitectura

P: ¿Por qué separar frontend y backend?
R: Permite escalado independiente, ciclos de despliegue separados,
   diferentes requerimientos de recursos, mejor aislamiento de seguridad.

P: ¿Por qué Docker Compose en lugar de Kubernetes?
R: Más simple para despliegue en una sola EC2, menos carga operativa,
   suficiente para la escala de un proyecto académico, más fácil de entender.

P: ¿Por qué Terraform en lugar de configuración manual en consola AWS?
R: Reproducible, control de versiones, automatizado, documentado,
   permite destrucción y recreación rápidas.

## Preguntas de Seguridad

P: ¿Cómo se protegen los secrets?
R: GitHub Secrets para CI/CD, variables de entorno para tiempo de ejecución,
   sin credenciales hardcodeadas en el código.

P: ¿Por qué contenedores no-root?
R: Principio de privilegio mínimo, prevención de escape de contenedor,
   cumplimiento de mejores prácticas de seguridad.

P: ¿Por qué subredes privadas para bases de datos?
R: Defensa en profundidad, las bases de datos nunca deben ser directamente
   accesibles desde internet.

## Preguntas de DevOps

P: ¿Qué sucede cuando haces push a la rama deploy?
R: GitHub Actions se activa → Validación → Build → Push de imágenes
   → Despliegue con Terraform → Despliegue vía SSH → Verificación de salud

P: ¿Cómo hacer rollback?
R: Hacer push del commit anterior, o usar `docker compose down` para detener,
   luego `docker compose up -d` para reiniciar con el código actual.

P: ¿Cuánto tarda el despliegue?
R: ~15-20 minutos (validación, build, push, despliegue, verificación de salud)

P: ¿Cómo destruir todo?
R: `cd infra && ./destroy.sh` - terraform destroy elimina todos los recursos AWS

# Referencia de Comandos

## Comandos Git
```bash
git init
git add .
git commit -m "Initial DevOps implementation"
git branch -M deploy
git remote add origin git@github.com:JONAHBRUZZI/evaluacion_devops.git
git push -u origin main
git push origin deploy
```

## Comandos Docker
```bash
# Construir
docker build -t evaluation-devops-frontend ./front_despacho

# Ejecutar
docker-compose up -d

# Logs
docker-compose logs -f

# Detener
docker-compose down

# Eliminar volúmenes
docker-compose down -v
```

## Comandos Terraform
```bash
cd infra
./deploy.sh      # Desplegar
./destroy.sh     # Destruir
./update.sh      # Actualizar frontend

# Manual
terraform init
terraform plan
terraform apply
terraform destroy
```

## Comandos AWS
```bash
# Obtener IP de EC2
cd infra && terraform output ec2_public_ip

# SSH
ssh -i ~/.ssh/evaluation-devops-key.pem ubuntu@<ip>

# En EC2
docker ps
docker compose -f /app/docker-compose.yml logs -f
```

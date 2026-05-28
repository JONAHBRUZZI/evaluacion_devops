# Lecciones Aprendidas - Evaluation DevOps

## Errores encontrados y soluciones durante el proyecto

| # | Error | Causa | Solución |
|---|-------|-------|----------|
| 1 | `wget` no existe en `nginx:alpine` | Alpine base no incluye wget | Instalar `curl` + `apk add --no-cache curl` |
| 2 | `nginx: mkdir() /var/cache/nginx/client_temp failed (13: Permission denied)` | Usuario `nginx` sin permisos en `/var/cache/nginx` | `chown -R nginx:nginx /var/cache/nginx /var/run` en Dockerfile |
| 3 | `nginx: open() /run/nginx.pid failed` | Usuario no-root no puede escribir en `/run` | `pid /tmp/nginx.pid;` en nginx.conf |
| 4 | `./mvnw: exit code 126` | Maven wrapper sin permisos de ejecución | `chmod +x mvnw` antes del build |
| 5 | `./mvnw: can't open .mvn/wrapper/maven-wrapper.properties` | Ruta `.mvn` copiada sin el punto | `COPY .mvn ./.mvn` (no `./mvn`) |
| 6 | YAML: `mapping values are not allowed here` | `:` dentro de string interpretado como YAML mapping | Usar `run: \|` en vez de `run: "texto: valor"` |
| 7 | Terraform: `InvalidGroup.Duplicate` | State perdido entre runs → SG duplicado | `name_prefix` en vez de `name` fijo |
| 8 | Terraform: `InvalidKeyPair.Duplicate` | Key SSH con nombre fijo ya existe | `random_string.suffix` para nombre único |
| 9 | Terraform: `Your query returned no results` | Filtro AMI incorrecto | Usar nombre exacto: `ubuntu/images/hvm-ssd-gp3/ubuntu-noble-*` |
| 10 | Terraform: `UnauthorizedOperation: ec2:DescribeImages` | IAM bloquea lookup de AMIs | Pasar AMI ID fijo, usar `count` condicional en data source |
| 11 | Terraform: `VpcLimitExceeded` | VPCs huérfanas de runs fallidos | Limpiar recursos manualmente, usar state persistente |
| 12 | Terraform: `t3.medium not supported in us-east-1e` | Tipo de instancia no disponible en esa AZ | Cambiar a `t2.medium` (compatible todas las AZs) |
| 13 | Terraform: `MissingPublicKey` | Archivo SSH no existe en el runner | Generar key con `tls_private_key` en Terraform |
| 14 | Terraform: `Duplicate variable declaration` | Variables.tf con entrada duplicada | Revisar diff antes de commit |
| 15 | Docker: `compose is not a docker command` | Plugin docker compose no instalado | Instalar binario standalone `docker-compose` |
| 16 | `cat: .env: Permission denied` | Directorio `/app` creado por root | `sudo tee` o `chown ec2-user:ec2-user /app` |
| 17 | MySQL: `Public Key Retrieval is not allowed` | MySQL 8.0 usa `caching_sha2_password` | `--default-authentication-plugin=mysql_native_password` |
| 18 | SSH: `handshake failed: no supported methods remain` | Llave privada incorrecta en secrets | Usar la llave correcta del lab (`labsuser.pem`) |
| 19 | Terraform: state perdido entre runs del pipeline | Runner efímero, state local | Artifact de GitHub Actions para persistir `terraform.tfstate` |
| 20 | Health checks externos fallan (exit code 7) | Learner Lab bloquea tráfico HTTP inbound | Verificar internamente con `curl localhost`, health checks `continue-on-error` |

---

## Tips para crear pipelines CI/CD robustos

### 1. Siempre validar YAML antes de pushear
```bash
python -c "import yaml; yaml.safe_load(open('.github/workflows/deploy.yml'))"
```

### 2. Usar `continue-on-error` para pasos no críticos
```yaml
- name: Run ESLint
  continue-on-error: true
  run: npm run lint
```

### 3. Agregar `if: failure()` para cleanup automático
```yaml
- name: Cleanup on failure
  if: failure()
  run: terraform destroy -auto-approve
```

### 4. Compartir datos entre jobs con `outputs`
```yaml
outputs:
  ec2_public_ip: ${{ steps.get-ip.outputs.ec2_public_ip }}
# En otro job:
needs.terraform-deploy.outputs.ec2_public_ip
```

### 5. Validar Terraform antes de aplicar
```yaml
- terraform fmt -check -diff
- terraform validate
- terraform plan -out=tfplan
- terraform apply tfplan
```

### 6. Usar variables de entorno para secrets, nunca hardcodear
```yaml
env:
  TF_VAR_db_password: ${{ secrets.DB_PASSWORD }}
```

### 7. Siempre hacer `docker-compose down` antes de `up`
```bash
sudo docker-compose down || true
sudo docker-compose up -d
```

### 8. Healthcheck en Dockerfile + docker-compose
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:80/ || exit 1
```

### 9. Multi-stage builds para imágenes mínimas
```dockerfile
FROM node:20-alpine AS builder
# ... build ...
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

### 10. Siempre correr como usuario no-root
```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

---

## Persistencia de datos

### Estrategia implementada

```
┌──────────────────────────────────────────────┐
│ EC2 Instance (EBS)                           │
│  ┌────────────────────────────────────────┐  │
│  │ Docker Volume: mysql-data              │  │
│  │   → /var/lib/mysql (datos MySQL)       │  │
│  │   → Sobrevive: restart, down, pull     │  │
│  │   → NO sobrevive: terminate instance   │  │
│  └────────────────────────────────────────┘  │
└──────────────────────────────────────────────┘
```

### Qué persiste y qué no

| Evento | MySQL | Frontend | Backends |
|--------|-------|----------|----------|
| `docker restart` | Datos intactos | Intacto | Intacto |
| `docker-compose down && up` | Datos intactos | Nueva imagen | Nueva imagen |
| `docker pull && up` | Datos intactos | Actualizado | Actualizado |
| EC2 stop/start (Learner Lab) | Datos intactos | Contenedores reinician | Contenedores reinician |
| EC2 terminate | **DATOS PERDIDOS** | N/A | N/A |

### Comandos para verificar persistencia

```bash
# Ver volúmenes Docker
sudo docker volume ls

# Inspeccionar volumen MySQL
sudo docker volume inspect app_mysql-data

# Ver datos en MySQL
sudo docker exec evaluation-devops-mysql mysql -uroot -p -e "SHOW DATABASES;"
```

---

## Backups necesarios

### 1. Backup de MySQL (diario recomendado)

```bash
# Crear backup
sudo docker exec evaluation-devops-mysql mysqldump -uroot -p'MiPassword123!' \
  --all-databases > /home/ec2-user/backup_$(date +%Y%m%d).sql

# Restaurar backup
sudo docker exec -i evaluation-devops-mysql mysql -uroot -p'MiPassword123!' \
  < backup_20260101.sql
```

### 2. Backup automático con cron en EC2

```bash
# Agregar al crontab (cada día a las 2 AM)
echo "0 2 * * * docker exec evaluation-devops-mysql mysqldump -uroot -p'MiPassword123!' \
  --all-databases > /home/ec2-user/backups/backup_\$(date +\%Y\%m\%d).sql" | sudo crontab -
```

### 3. Backup de volumen Docker

```bash
# Crear backup del volumen completo
sudo docker run --rm -v app_mysql-data:/data -v /home/ec2-user/backups:/backup \
  alpine tar czf /backup/mysql-volume-backup.tar.gz -C /data .

# Restaurar volumen
sudo docker run --rm -v app_mysql-data:/data -v /home/ec2-user/backups:/backup \
  alpine tar xzf /backup/mysql-volume-backup.tar.gz -C /data
```

### 4. Backup de Terraform state

El state ya se persiste como artifact de GitHub Actions. Para backup adicional:

```bash
# Descargar state desde artifact
# O guardar en S3:
aws s3 cp terraform.tfstate s3://evaluation-devops-backups/terraform-$(date +%Y%m%d).tfstate
```

### 5. Plan de recuperación ante desastres

| Escenario | Recuperación |
|-----------|-------------|
| Contenedor cae | `docker-compose up -d` (auto-restart configurado) |
| EC2 se apaga (lab) | Volver a iniciar sesión, contenedores auto-arrancan |
| EC2 se termina | Reconstruir desde pipeline, restaurar backup MySQL |
| Datos corruptos | Restaurar último backup `.sql` |
| Pierdo acceso AWS | Renovar credenciales en GitHub Secrets, redeploy |

---

## Configuración de secrets en GitHub

### Lista completa de secrets requeridos

| Secret | Ejemplo | Notas |
|--------|---------|-------|
| `AWS_ACCESS_KEY_ID` | `ASIA...` | Del Learner Lab → AWS Details |
| `AWS_SECRET_ACCESS_KEY` | `abc123...` | Del Learner Lab → AWS Details |
| `AWS_SESSION_TOKEN` | `IQoJ...` | Del Learner Lab → AWS Details |
| `AWS_REGION` | `us-east-1` | Fijo para Learner Lab |
| `DOCKERHUB_USERNAME` | `jonahbruzzi` | Tu usuario de Docker Hub |
| `DOCKERHUB_TOKEN` | `dckr_pat_...` | Access token de Docker Hub |
| `DB_PASSWORD` | `MiPassword123!` | Contraseña para MySQL |
| `EC2_SSH_KEY` | Contenido de `labsuser.pem` | Del Learner Lab → Download PEM |

### Rotación de credenciales

Las credenciales del Learner Lab expiran cada ~4 horas. Pasos para rotar:

1. Ir a la consola del Learner Lab → **Start Lab**
2. Click **AWS Details** → copiar Access Key, Secret Key, Session Token
3. Ir a GitHub → Settings → Secrets → Actions
4. Actualizar `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`
5. Re-ejecutar el pipeline

---

## Resumen del stack final

```
┌──────────────────────────────────────────────────────────┐
│ GitHub → Docker Hub → EC2 (AWS Learner Lab)              │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │ Frontend │  │ Backend  │  │ Backend  │  │  MySQL   │ │
│  │ Nginx:80 │  │Ventas:80 │  │Despachos │  │   :3306  │ │
│  │ React    │  │   80     │  │  :8081   │  │  (8.0)   │ │
│  │ HEALTHY  │  │ HEALTHY  │  │ HEALTHY  │  │ HEALTHY  │ │
│  └──────────┘  └──────────┘  └──────────┘  └────┬─────┘ │
│                                                  │       │
│                                      Volumen     │       │
│                                      mysql-data  │       │
│                                      PERSISTENTE │       │
│                                                  │       │
└──────────────────────────────────────────────────────────┘
```
# ============================================
# DEVOPS EXPLANATION DOCUMENTATION
# ============================================

# 1. Containerization Design

## Frontend (React + Vite + Nginx)

### Multi-stage Build Strategy
```
Stage 1: Builder (node:20-alpine)
├── Install dependencies (npm ci)
├── Copy source code
├── Build production bundle (npm run build)
└── Output: /app/dist

Stage 2: Production (nginx:alpine)
├── Copy build artifacts from builder
├── Custom nginx configuration
├── Set proper file permissions
└── Run as non-root user (nginx)
```

### Security Implementation
- **Non-root user**: nginx user (uid 101)
- **Read-only filesystem**: Configured via nginx.conf
- **Minimal image**: Alpine-based (~15MB base)
- **Healthcheck**: HTTP check every 30s

### Performance Optimization
- **Layer caching**: Dependencies installed before code copy
- **Nginx gzip**: Compression for text assets
- **Static file serving**: Direct from nginx, no node overhead
- **Asset caching**: Immutable URLs for hashed files

### AWS Compatibility
- **Port 80 exposed**: Standard HTTP for EC2 security groups
- **Healthcheck endpoint**: / returns 200 for ELB/ALB integration
- **Minimal attack surface**: No shell, no package managers in final image

## Backend Ventas (Spring Boot)

### Multi-stage Build Strategy
```
Stage 1: Builder (eclipse-temurin:17-jdk-alpine)
├── Copy pom.xml
├── Download Maven dependencies
├── Copy source code
├── Build JAR (./mvnw package)
└── Output: /app/target/*.jar

Stage 2: Production (eclipse-temurin:17-jre-alpine)
├── Create non-root user (appuser:appgroup)
├── Copy JAR from builder
├── Set proper permissions
└── Run as non-root user
```

### Security Implementation
- **Non-root execution**: appuser (uid 1001)
- **No shell access**: Only Java process running
- **Filesystem read-only**: /app only, logs to stdout
- **Healthcheck**: Actuator endpoint every 30s

### AWS Compatibility
- **Java 17 LTS**: Compatible with Amazon Corretto
- **Actuator health**: /actuator/health for monitoring
- **Environment variables**: Native Spring support for AWS secrets
- **Port 8080**: Internal only, not exposed to internet

## Backend Despachos (Spring Boot)

Same architecture as Ventas, with:
- **Port 8081**: Different from Ventas to enable parallel deployment
- **Separate container**: Independent scaling capability
- **Shared network**: Communication via Docker DNS

# 2. Docker Compose Architecture

## Service Definitions

### Frontend Service
```yaml
image: evaluation-devops-frontend:latest
ports:
  - "80:80"           # Public access
networks:
  - evaluation-network
depends_on:
  - backend-ventas    # Healthcheck condition
  - backend-despachos # Healthcheck condition
restart: unless-stopped
healthcheck:
  test: ["CMD", "wget", "-q", "http://localhost:80/"]
```

### Backend Ventas Service
```yaml
image: evaluation-devops-backend-ventas:latest
ports:
  - "8080:8080"       # Internal only
environment:
  - DB_ENDPOINT=${DB_ENDPOINT}
  - DB_PASSWORD=${DB_PASSWORD}
networks:
  - evaluation-network
restart: unless-stopped
healthcheck:
  test: ["CMD", "wget", "-q", "http://localhost:8080/actuator/health"]
```

### Backend Despachos Service
```yaml
image: evaluation-devops-backend-despachos:latest
ports:
  - "8081:8081"       # Internal only
environment:
  - DB_ENDPOINT=${DB_ENDPOINT}
  - DB_PASSWORD=${DB_PASSWORD}
networks:
  - evaluation-network
restart: unless-stopped
healthcheck:
  test: ["CMD", "wget", "-q", "http://localhost:8081/actuator/health"]
```

## Network Architecture

```
┌─────────────────────────────────────────────────┐
│           evaluation-network (bridge)           │
│                                                 │
│   Driver: bridge                                │
│   Subnet: 172.20.0.0/16                        │
│                                                 │
│   DNS Resolution:                               │
│   ├── frontend → 172.20.0.2                   │
│   ├── backend-ventas → 172.20.0.3             │
│   └── backend-despachos → 172.20.0.4           │
│                                                 │
│   Frontend can reach backends by name:          │
│   • http://backend-ventas:8080                 │
│   • http://backend-despachos:8081              │
└─────────────────────────────────────────────────┘
```

## Persistence Strategy

### Volume Configuration
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

### What Persists
| Volume | Data | Survives |
|--------|------|----------|
| frontend-data | Uploaded files, cache | Container restart |
| db-data | Database files | Container restart |

### What Doesn't Persist
- Container filesystem (code, configs)
- tmp directories
- Logs (stdout)

### Data Protection
- Volumes survive `docker compose down`
- Volumes survive `docker compose up -d`
- Volumes DON'T survive `docker compose down -v`
- EBS recommended for database in production

# 3. CI/CD Pipeline Explanation

## Pipeline Trigger

```yaml
on:
  push:
    branches:
      - deploy
```

When code is pushed to `deploy` branch:
1. GitHub Actions automatically triggers
2. Full pipeline executes
3. No manual intervention required

## Pipeline Stages

### Stage 1: Validation
```
├── Checkout code
├── Install dependencies (npm ci)
├── ESLint (code quality)
└── Build (compile check)
```

### Stage 2: Build Backends
```
├── Backend Ventas
│   ├── Setup Java 17
│   └── Maven package
│
└── Backend Despachos
    ├── Setup Java 17
    └── Maven package
```

### Stage 3: Docker Build & Push
```
├── Login to Docker Hub
├── Build frontend image
├── Push frontend image
├── Build backend-ventas image
├── Push backend-ventas image
├── Build backend-despachos image
└── Push backend-despachos image
```

### Stage 4: Terraform Deploy
```
├── Configure AWS credentials
├── Terraform init
├── Terraform fmt
├── Terraform validate
├── Terraform plan
└── Terraform apply
```

### Stage 5: EC2 Deployment
```
├── Wait for EC2 initialization (2 min)
├── SSH to EC2
├── Login to Docker Hub
├── Pull latest images
├── Stop existing containers
└── Start new containers
```

### Stage 6: Health Check
```
├── Check frontend (/ port 80)
├── Check backend-ventas (/actuator/health)
├── Check backend-despachos (/actuator/health)
└── Report status
```

## Secrets Configuration

Required GitHub Secrets:
| Secret | Purpose |
|--------|---------|
| AWS_ACCESS_KEY_ID | AWS authentication |
| AWS_SECRET_ACCESS_KEY | AWS authentication |
| AWS_SESSION_TOKEN | Temporary AWS session |
| AWS_REGION | Target region |
| DOCKERHUB_USERNAME | Image push authentication |
| DOCKERHUB_TOKEN | Image push authentication |
| DB_PASSWORD | Backend database password |
| EC2_SSH_KEY | SSH access to EC2 |

## Docker Hub Justification

Why Docker Hub over ECR/other registries?

1. **Simplicity**: No registry configuration in pipeline
2. **Free tier**: Unlimited public repos, 1 private
3. **Maturity**: Industry standard, well-documented
4. **Integration**: Native `docker/login-action` support
5. **Speed**: Global CDN, fast pulls worldwide
6. **Cost**: No egress fees for public images

For production with sensitive images:
- AWS ECR with VPC endpoints
- Azure Container Registry
- Google Artifact Registry

# 4. DevOps Principles Applied

## Infrastructure as Code (IaC)

**Terraform Benefits**:
- Version controlled infrastructure
- Reproducible deployments
- Consistent environments
- Rapid destruction and recreation
- State tracking and versioning

**Implementation**:
```bash
# Deploy
./deploy.sh

# Destroy
./destroy.sh
```

## Containerization (Docker)

**Benefits**:
- Consistent environments (dev = prod)
- Isolation between services
- Resource limits and allocation
- Rapid scaling
- Rollback capability

**Implementation**:
- Multi-stage builds
- Non-root users
- Healthchecks
- Resource constraints

## Continuous Integration & Deployment (CI/CD)

**Benefits**:
- Automated testing
- Consistent deployments
- Fast feedback loop
- Reduced human error
- Audit trail

**Implementation**:
- GitHub Actions
- Automated triggers
- Environment promotion
- Health checks

## Immutable Infrastructure

**Principle**: Never modify running instances, always replace

**Implementation**:
- New AMI/image for changes
- Blue-green deployments
- Infrastructure as code
- Versioned containers

## Security by Design

**Implementation**:
- Non-root containers
- Least privilege security groups
- No hardcoded secrets
- Secrets via environment variables
- Network segmentation (public/private subnets)

## Scalability Considerations

**Horizontal Scaling**:
- Stateless services
- External database
- Load balancer ready

**Vertical Scaling**:
- t3.medium default (adjustable)
- EBS volume expansion
- Docker resource limits

## Monitoring & Health Checks

**Health Endpoints**:
- Frontend: `http://localhost:80/`
- Backend Ventas: `http://localhost:8080/actuator/health`
- Backend Despachos: `http://localhost:8081/actuator/health`

**Automated Checks**:
- Docker healthcheck
- GitHub Actions health step
- ELB/ALB integration ready
# ============================================
# EVIDENCE GUIDE FOR ACADEMIC DEFENSE
# ============================================

# Evidence Checklist

## GitHub Actions Evidence

### 1. Workflow Execution
- [ ] GitHub Actions triggered on `deploy` branch push
- [ ] All jobs completed successfully
- [ ] Screenshots of each job status

### 2. Validation Stage
- [ ] ESLint passed
- [ ] Frontend build successful
- [ ] Backend Maven build successful

### 3. Docker Build & Push
- [ ] Images built successfully
- [ ] Images pushed to Docker Hub
- [ ] Tags visible on Docker Hub

### 4. Terraform Deploy
- [ ] Terraform init successful
- [ ] Terraform plan output
- [ ] Terraform apply completed
- [ ] EC2 instance created

### 5. EC2 Deployment
- [ ] SSH connection successful
- [ ] Docker images pulled
- [ ] Containers started

### 6. Health Check
- [ ] Frontend returning 200
- [ ] Backends returning 200

## Terraform Evidence

### 1. State Files
- [ ] terraform.tfstate exists
- [ ] State contains all resources
- [ ] State locked (if using remote backend)

### 2. Plan Output
- [ ] Resources to create
- [ ] Resources to modify
- [ ] Resources to destroy

### 3. Apply Output
- [ ] Public IP displayed
- [ ] All resources created
- [ ] No errors

## Docker Evidence

### 1. Local Testing
```bash
# Build images
docker build -f front_despacho/Dockerfile -t test-frontend ./front_despacho
docker build -f back-Ventas_SpringBoot/Dockerfile -t test-backend-ventas ./back-Ventas_SpringBoot
docker build -f back-Despachos_SpringBoot/Dockerfile -t test-backend-despachos ./back-Despachos_SpringBoot

# Run compose
docker-compose up -d

# Verify containers
docker ps

# View logs
docker-compose logs -f
```

### 2. Container Status
- [ ] All containers running
- [ ] No restarts (healthcheck passing)
- [ ] Proper ports exposed

### 3. Network Verification
```bash
# View networks
docker network ls
docker network inspect evaluation_devops_evaluation-network
```

### 4. Volume Verification
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect evaluation_devops_frontend-data
```

## AWS EC2 Evidence

### 1. Instance Created
- [ ] EC2 instance running
- [ ] Public IP assigned
- [ ] Security groups configured

### 2. SSH Access
```bash
ssh -i ~/.ssh/evaluation-devops-key.pem ubuntu@<public-ip>
```

### 3. Docker Installation
```bash
docker --version
docker compose version
```

### 4. Containers Running
```bash
docker ps
docker compose -f /app/docker-compose.yml ps
```

### 5. Services Accessible
```bash
curl http://localhost
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
```

## Network Evidence

### Security Groups
- Port 80 (HTTP) open to 0.0.0.0/0
- Port 443 (HTTPS) open to 0.0.0.0/0
- Port 22 (SSH) open to 0.0.0.0/0
- Ports 8080, 8081 open to 10.0.0.0/16 only

### VPC Configuration
- VPC with CIDR 10.0.0.0/16
- Public subnet (10.0.1.0/24)
- Private subnet (10.0.2.0/24)
- Internet Gateway attached
- Route tables configured

## Persistence Evidence

### 1. Volume Creation
```bash
docker volume create test-volume
docker volume inspect test-volume
```

### 2. Data Survival Test
```bash
# Create data
docker exec container mkdir /data/test
docker exec container touch /data/test/file.txt

# Restart container
docker restart container

# Verify data exists
docker exec container ls /data/test
```

### 3. Production Data
- [ ] Database data persists
- [ ] Uploaded files persist
- [ ] Configuration persists

## Common Issues and Troubleshooting

### Docker Build Fails
```
Problem: Multi-stage build fails
Solution: Check COPY paths, ensure files exist
```

### Container Won't Start
```
Problem: Port already in use
Solution: Check for other containers using same port
```

### Healthcheck Fails
```
Problem: Service not responding
Solution: Check logs, verify port mapping
```

### Terraform State Locked
```
Problem: State locked by another process
Solution: terraform force-unlock <lock-id>
```

### EC2 SSH Timeout
```
Problem: Cannot connect to EC2
Solution: Check security group, verify key permissions
```

# Defense Answers

## Architecture Questions

Q: Why separate frontend and backend?
A: Enables independent scaling, separate deployment cycles,
   different resource requirements, better security isolation.

Q: Why Docker Compose over Kubernetes?
A: Simpler for single EC2 deployment, less operational overhead,
   sufficient for academic project scale, easier to understand.

Q: Why Terraform over manual AWS console setup?
A: Reproducible, version controlled, automated, documented,
   enables rapid destruction and recreation.

## Security Questions

Q: How are secrets protected?
A: GitHub Secrets for CI/CD, environment variables for runtime,
   no hardcoded credentials in code.

Q: Why non-root containers?
A: Principle of least privilege, container escape prevention,
   compliance with security best practices.

Q: Why private subnets for databases?
A: Defense in depth, databases should never be directly
   accessible from internet.

## DevOps Questions

Q: What happens when you push to deploy branch?
A: GitHub Actions triggers → Validation → Build → Push images
   → Terraform deploy → SSH deploy → Health check

Q: How do you rollback?
A: Push previous commit, or use `docker compose down` to stop,
   then `docker compose up -d` to restart with current code.

Q: How long does deployment take?
A: ~15-20 minutes (validation, build, push, deploy, health check)

Q: How do you destroy everything?
A: `cd infra && ./destroy.sh` - terraform destroy removes all AWS resources

# Commands Reference

## Git Commands
```bash
git init
git add .
git commit -m "Initial DevOps implementation"
git branch -M deploy
git remote add origin git@github.com:JONAHBRUZZI/evaluacion_devops.git
git push -u origin main
git push origin deploy
```

## Docker Commands
```bash
# Build
docker build -t evaluation-devops-frontend ./front_despacho

# Run
docker-compose up -d

# Logs
docker-compose logs -f

# Stop
docker-compose down

# Remove volumes
docker-compose down -v
```

## Terraform Commands
```bash
cd infra
./deploy.sh      # Deploy
./destroy.sh     # Destroy
./update.sh      # Update frontend

# Manual
terraform init
terraform plan
terraform apply
terraform destroy
```

## AWS Commands
```bash
# Get EC2 IP
cd infra && terraform output ec2_public_ip

# SSH
ssh -i ~/.ssh/evaluation-devops-key.pem ubuntu@<ip>

# On EC2
docker ps
docker compose -f /app/docker-compose.yml logs -f
```
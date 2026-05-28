#!/bin/bash
set -e

echo "=== Script de instalación Docker ==="
echo "Proyecto: ${PROJECT_NAME}"

export DEBIAN_FRONTEND=noninteractive

echo "1. Installing Docker..."
yum update -y
yum install -y docker

echo "2. Configuring Docker..."
systemctl enable docker
systemctl start docker

echo "3. Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

echo "4. Adding ec2-user to docker group..."
usermod -aG docker ec2-user

echo "8. Docker version verification..."
docker --version
docker-compose --version

echo "9. Creating project directory..."
mkdir -p /app
mkdir -p /docker-data
chown -R ec2-user:ec2-user /app

echo "10. Creating Docker Compose file..."
cat > /app/docker-compose.yml << 'EOF'
version: '3.8'

services:
  frontend:
    image: ${DOCKERHUB_USERNAME}/evaluation-devops-frontend:latest
    container_name: evaluation-devops-frontend
    ports:
      - "80:80"
    networks:
      - evaluation-network
    depends_on:
      backend-ventas:
        condition: service_healthy
      backend-despachos:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s

  backend-ventas:
    image: ${DOCKERHUB_USERNAME}/evaluation-devops-backend-ventas:latest
    container_name: evaluation-devops-backend-ventas
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DB_ENDPOINT=$${DB_ENDPOINT}
      - DB_PORT=$${DB_PORT}
      - DB_NAME=$${DB_NAME}
      - DB_USERNAME=$${DB_USERNAME}
      - DB_PASSWORD=$${DB_PASSWORD}
    ports:
      - "8080:8080"
    networks:
      - evaluation-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

  backend-despachos:
    image: ${DOCKERHUB_USERNAME}/evaluation-devops-backend-despachos:latest
    container_name: evaluation-devops-backend-despachos
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DB_ENDPOINT=$${DB_ENDPOINT}
      - DB_PORT=$${DB_PORT}
      - DB_NAME=$${DB_NAME}
      - DB_USERNAME=$${DB_USERNAME}
      - DB_PASSWORD=$${DB_PASSWORD}
    ports:
      - "8081:8081"
    networks:
      - evaluation-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8081/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

networks:
  evaluation-network:
    driver: bridge
EOF

echo "11. Creating .env file..."
cat > /app/.env << 'EOF'
SPRING_PROFILES_ACTIVE=prod
DB_ENDPOINT=$${DB_ENDPOINT}
DB_PORT=$${DB_PORT}
DB_NAME=$${DB_NAME}
DB_USERNAME=$${DB_USERNAME}
DB_PASSWORD=$${DB_PASSWORD}
EOF

echo "12. Creating startup script..."
cat > /app/start.sh << 'EOF'
#!/bin/bash
set -e

echo "=== Starting Evaluation DevOps Stack ==="

# Pull latest images
echo "Pulling latest images..."
docker compose -f /app/docker-compose.yml pull

# Stop existing containers
echo "Stopping existing containers..."
docker compose -f /app/docker-compose.yml down

# Start services
echo "Starting services..."
docker compose -f /app/docker-compose.yml up -d

# Wait for health checks
echo "Waiting for services to be healthy..."
sleep 30

# Verify services
echo "Container status:"
docker compose -f /app/docker-compose.yml ps

echo ""
echo "=== Stack started successfully ==="
echo "Frontend: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo 'localhost')"
echo "Backend Ventas: http://localhost:8080"
echo "Backend Despachos: http://localhost:8081"
EOF

chmod +x /app/start.sh

echo "=== Docker installation completed ==="
# Evaluacion DevOps - Sistema Fullstack

## Descripción
Proyecto fullstack con React frontend y Spring Boot backends para gestión de despachos y ventas.

## Arquitectura
```
Frontend (React/Vite) → Backend Ventas (8080) → MySQL
                     → Backend Despachos (8081) → MySQL
```

## Tech Stack
- **Frontend**: React 18, Vite 5, Tailwind CSS, React Router 6
- **Backend**: Spring Boot 3.4.4, Java 17, Spring Data JPA
- **Database**: MySQL 8.x (AWS RDS configurable)
- **Container**: Docker, Docker Compose
- **Infraestructura**: Terraform, AWS EC2
- **CI/CD**: GitHub Actions

## Componentes
1. `front_despacho/` - React frontend para administración de despachos
2. `back-Ventas_SpringBoot/` - Spring Boot API para gestión de ventas
3. `back-Despachos_SpringBoot/` - Spring Boot API para gestión de despachos

## Puertos
| Servicio | Puerto | Acceso |
|----------|--------|--------|
| Frontend | 5173 | Público |
| Backend Ventas | 8080 | Privado |
| Backend Despachos | 8081 | Privado |
| MySQL | 3306 | Privado |

## Primeros Pasos

### Desarrollo Local
```bash
# Frontend
cd front_despacho && npm install && npm run dev

# Backend Ventas
cd back-Ventas_SpringBoot/Springboot-API-REST && ./mvnw spring-boot:run

# Backend Despachos
cd back-Despachos_SpringBoot/Springboot-API-REST-DESPACHO && ./mvnw spring-boot:run
```

### Docker
```bash
docker-compose up -d
```

### Terraform
```bash
cd infra && ./deploy.sh
```

## Documentación
- [Architecture](docs/architecture.md)
- [DevOps Explanation](docs/devops-explanation.md)
- [Evidence Guide](docs/evidence.md)
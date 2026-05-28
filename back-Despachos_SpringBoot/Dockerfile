# Multi-stage build for Spring Boot Despachos Backend
FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /app

COPY Springboot-API-REST-DESPACHO/pom.xml .
COPY Springboot-API-REST-DESPACHO/mvnw .
COPY Springboot-API-REST-DESPACHO/.mvn ./mvn

RUN chmod +x mvnw

COPY Springboot-API-REST-DESPACHO/src ./src

RUN ./mvnw package -DskipTests

FROM eclipse-temurin:17-jre-alpine

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=builder /app/target/*.jar app.jar

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD wget --no-redirect --tries=1 -q http://localhost:8081/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "-Dserver.port=8081", "app.jar"]
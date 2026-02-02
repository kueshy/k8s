# Use a base image with JDK (multi-stage build for optimization)
#FROM eclipse-temurin:17-jdk-alpine AS build
#WORKDIR /app
#
#COPY pom.xml .
#RUN mvn dependency:go-offline -B
#
#COPY src ./src
#RUN ./mvnw clean package -DskipTests -B  # Assuming Maven wrapper; use mvn if not
#
#FROM eclipse-temurin:17-jre-alpine
#RUN addgroup -S appgroup && adduser -S appuser -G appgroup
#
#WORKDIR /app
#
#ARG JAR_FILE=target/k8s-0.0.1-SNAPSHOT.jar
#COPY --from=build /app/${JAR_FILE} app.jar
#
#RUN chown -R appuser:appgroup /app
#
#USER appuser
#
#HEALTHCHECK --interval=30s --timeout=3s --start-period=90s --retries=3 \
#  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1
#
#EXPOSE 8080
#
#ENV JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UseStringDeduplication" \
#    SPRING_PROFILES_ACTIVE=production
#
##ENTRYPOINT ["java", "-jar", "app.jar"]
#ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]

# Build stage
FROM maven:3.9-amazoncorretto-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Run stage
FROM amazoncorretto:17-alpine
WORKDIR /app
COPY --from=build /app/target/k8s.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
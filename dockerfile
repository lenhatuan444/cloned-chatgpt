# Stage 1: Build the application
FROM eclipse-temurin:21-jdk-alpine AS builder

WORKDIR /app

# Copy only the necessary files to cache dependencies
COPY mvnw pom.xml ./
COPY .mvn .mvn

# Ensure Maven wrapper is executable
RUN chmod +x mvnw

# Download dependencies first (cached unless pom.xml changes)
RUN ./mvnw dependency:go-offline

# Copy the rest of the source code
COPY . .

# Build the application without running tests (faster)
RUN ./mvnw clean package -DskipTests

# Stage 2: Run the application with a minimal image
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

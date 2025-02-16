# Use Eclipse Temurin JDK 21 as the base image
FROM eclipse-temurin:21-jdk-alpine AS builder

# Set the working directory for the build stage
WORKDIR /app

# Copy Maven wrapper and pom.xml first to cache dependencies
COPY mvnw pom.xml ./
COPY .mvn .mvn

# Grant execute permission to Maven wrapper
RUN chmod +x mvnw

# Download dependencies (faster subsequent builds)
RUN ./mvnw dependency:go-offline

# Copy the entire project
COPY . .

# Build the application
RUN ./mvnw clean package -DskipTests

# Use a smaller runtime image for the final stage
FROM eclipse-temurin:21-jre-alpine

# Set working directory
WORKDIR /app

# Copy the built JAR file from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose port 8080
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

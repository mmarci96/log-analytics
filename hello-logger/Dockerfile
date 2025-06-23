FROM docker.io/gradle:8-jdk21 AS build

WORKDIR /app

COPY gradlew .
COPY gradle/wrapper gradle/wrapper

COPY build.gradle .
COPY settings.gradle .
COPY src ./src

RUN ./gradlew clean build

FROM docker.io/library/eclipse-temurin:21-jdk-alpine

RUN addgroup -S spring && adduser -S -G spring spring

WORKDIR /app

COPY --from=build /app/build/libs/hello-logger-*.jar app.jar

RUN chown -R spring:spring /app

USER spring

ENTRYPOINT ["java", "-jar", "app.jar"]

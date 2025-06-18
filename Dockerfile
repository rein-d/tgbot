FROM maven:3.9.9-eclipse-temurin-21-alpine as builder
WORKDIR /app
COPY . /app/.
RUN mvn clean package -Dmaven.test.skip=true

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/tgbot-*.jar /app/tgbot.jar
EXPOSE 9000
ENTRYPOINT ["java", "-jar", "/app/tgbot.jar"]

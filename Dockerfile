#FROM maven:3.9.9-eclipse-temurin-21-alpine as builder
#WORKDIR /app
#COPY . /app/.
#RUN mvn -f /app/pom.xml clean package -Dmaven.test.skip=true
#
#FROM eclipse-temurin:21-jre-alpine
#WORKDIR /app
#COPY --from=builder /app/target/*.jar /app/*.jar
#EXPOSE 9000
#ENTRYPOINT ["java", "-jar", "/app/*.jar"]


# Этап сборки с кэшированием зависимостей Maven
FROM maven:3.9.9-eclipse-temurin-21-alpine as builder
RUN mkdir -p /home/app
WORKDIR /home/app


ADD pom.xml /home/app
ADD src /home/app/src


RUN mvn clean package
EXPOSE 9000

# Используем форму JSON-массива для ENTRYPOINT
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
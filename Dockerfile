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

WORKDIR /app

# 1. Копируем только POM-файл сначала (для кэширования зависимостей)
COPY pom.xml .

# 2. Скачиваем все зависимости (этот слой кэшируется, пока pom.xml не меняется)
RUN mvn dependency:go-offline -B

# 3. Копируем исходный код
COPY src src

# 4. Собираем приложение (используем кэшированные зависимости)
RUN mvn package -Dmaven.test.skip=true -Dmaven.main.skip -Dmaven.source.skip -Dspring-boot.repackage.skip=true && \
    find /app/target -name '*.jar' -exec mv {} /app/target/app.jar \;

# Финальный образ
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Копируем JAR с фиксированным именем
COPY --from=builder /app/target/app.jar ./app.jar

EXPOSE 9000

# Используем форму JSON-массива для ENTRYPOINT
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
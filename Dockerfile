#FROM eclipse-temurin:21-jdk as builder
#ENV RELEASE=21
#
#RUN groupadd --gid 1500 spring-app \
#    && useradd --uid 1500 --gid spring-app --shell /bin/bash --create-home spring-app
#
#USER spring-app:spring-app
#WORKDIR /opt/build
#
#COPY ./target/tgbot-*.jar ./application.jar
#
#RUN java -Djarmode=layertools -jar application.jar extract
#RUN $JAVA_HOME/bin/jlink \
#    --add-modules `jdeps --ignore-missing-deps -q -recursive --multi-release ${RELEASE} --print-module-deps -cp 'dependencies/BOOT-INF/lib/*':'snapshot-dependencies/BOOT-INF/lib/*' application.jar` \
#    --strip-debug \
#    --no-man-pages \
#    --no-header-files \
#    --compress=2 \
#    --output jdk
#
#FROM debian:buster-slim
#
#ARG BUILD_PATH=/opt/build
#ENV JAVA_HOME=/opt/jdk
#ENV PATH=${JAVA_HOME}/bin:${PATH}
#
#RUN groupadd --gid 1500 spring-app \
#    && useradd --uid 1500 --gid spring-app --shell /bin/bash --create-home spring-app
#
#USER spring-app:spring-app
#WORKDIR /opt/workspace
#
#COPY --from=builder $BUILD_PATH/jdk $JAVA_HOME
#COPY --from=builder $BUILD_PATH/spring-boot-loader/ ./
#COPY --from=builder $BUILD_PATH/dependencies/ ./
#COPY --from=builder $BUILD_PATH/snapshot-dependencies/ ./
#COPY --from=builder $BUILD_PATH/application/ ./
#
#EXPOSE 9000
#ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
########################################################################################
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

# 2. Скачиваем все зависимости
RUN mvn dependency:go-offline -B

# 3. Копируем исходный код
COPY src src

# 4. Собираем приложение с явным указанием главного класса
RUN mvn package -Dmaven.test.skip=true -Dmaven.main.skip -Dmaven.source.skip && \
    # Находим главный класс в MANIFEST.MF
    MAIN_CLASS=$(unzip -p target/*.jar META-INF/MANIFEST.MF | grep "Start-Class" | cut -d' ' -f2 | tr -d '\r') && \
    # Перепаковываем JAR с явным указанием главного класса
    echo "Main-Class: $MAIN_CLASS" > manifest.txt && \
    jar xf target/*.jar && \
    jar cfm app.jar manifest.txt org BOOT-INF META-INF

# Финальный образ
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Копируем перепакованный JAR
COPY --from=builder /app/app.jar ./app.jar

EXPOSE 9000
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
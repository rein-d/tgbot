#FROM eclipse-temurin:21-jdk as builder
#ENV RELEASE=21
#
#RUN groupadd --gid 999 spring-app \
#    && useradd --uid 999 --gid spring-app --shell /bin/bash --create-home spring-app
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
#RUN groupadd --gid 999 spring-app \
#    && useradd --uid 999 --gid spring-app --shell /bin/bash --create-home spring-app
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

FROM maven:3.9.9-eclipse-temurin-21-alpine as builder
WORKDIR /app
COPY . /app/.
RUN mvn -f /app/pom.xml clean package -Dmaven.test.skip=true

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar /app/*.jar
EXPOSE 9000
ENTRYPOINT ["java", "-jar", "/app/*.jar"]
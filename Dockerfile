# Build Stage
FROM openjdk:17-jdk-alpine as build
RUN mkdir -p /app/source
COPY . /app/source
WORKDIR /app/source
RUN chmod +x mvnw
RUN ./mvnw clean package

# Non root user configuration
RUN addgroup -S -g 10001 appGrp \
  && adduser -S -D -u 10000 -s /sbin/nologin -h /app -G appGrp app \
  && chown -R 10000:10001 /app

# Running stage
FROM build as runtime
COPY --from=build /app/source/target/*.jar /app/app.jar
EXPOSE 8080

USER 10000:10001
ENTRYPOINT [ "java","-Djava.security.egd=file:/dev/./urandom","-jar","/app/app.jar" ]
# Stage 1 Build the Spring Project into a jar file
FROM openjdk as builder
RUN yum install git -y \
    && git clone https://github.com/spring-projects/spring-petclinic.git \
    && cd spring-petclinic 
    && ./mvnw package


# Stage 2 Run the jar file from previous build
FROM openjdk
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring
COPY --from=builder /src/target /build
WORKDIR /build
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "spring-petclinic-2.3.1.BUILD-SNAPSHOT.jar"]
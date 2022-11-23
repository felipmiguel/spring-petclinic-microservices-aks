FROM openjdk:8-jdk-slim
# takes the jar file as an argument
# assumes the application entry port is 8080
EXPOSE 8080

# exposes debug port
EXPOSE 8000

# The application's jar file
# ARG JAR_FILE=${ARTIFACT_NAME}

# Add the application's jar to the container
ADD ./target/spring-petclinic-vets-service-2.5.1.jar app.jar

# Run the jar file
ENTRYPOINT ["java","-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000", "-jar","/app.jar"]